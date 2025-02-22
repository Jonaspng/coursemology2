# frozen_string_literal: true
class Course::Forum::Import < ApplicationRecord
  include Workflow

  workflow do
    state :not_imported do
      event :start_importing, transitions_to: :importing
    end
    state :importing do
      event :finish_importing, transitions_to: :imported
      event :cancel_importing, transitions_to: :not_imported
    end
    state :imported do
      event :delete_import, transitions_to: :not_imported
    end
  end

  belongs_to :course, class_name: 'Course', foreign_key: :course_id, inverse_of: :forum_imports
  belongs_to :imported_forum, class_name: 'Course::Forum', foreign_key: :imported_forum_id
  belongs_to :job, class_name: 'TrackableJob::Job', inverse_of: nil, optional: true
  has_many :discussion_references, class_name: 'Course::Forum::DiscussionReference',
                                   inverse_of: :forum_import, autosave: true
  has_many :discussions, through: :discussion_references, autosave: true

  validates :course, presence: true
  validates :imported_forum, presence: true
  validates :workflow_state, length: { maximum: 255 }, presence: true

  def self.forum_importing!(forum_imports, current_user)
    return if forum_imports.empty?

    Course::Forum::ImportingJob.perform_later(forum_imports.pluck(:id), current_user).tap do |job|
      forum_imports.update_all(job_id: job.job_id)
    end
  end

  def self.destroy_imported_discussions(forum_import_ids)
    ActiveRecord::Base.transaction do
      forum_imports = Course::Forum::Import.where(id: forum_import_ids)
      forum_imports.each do |forum_import|
        # Only process forum_imports that are in 'imported' state
        return false if forum_import.workflow_state != 'imported'

        forum_import.discussion_references.destroy_all
        forum_import.delete_import!
        forum_import.save!
      end
    end
    true
  end

  def build_discussions!(current_user)
    topics = imported_forum.topics
    topics.each do |topic|
      posts = topic.posts.order(created_at: :asc)
      sanitized_topic_title = ActionController::Base.helpers.strip_tags(topic[:title])
      topic_title = sanitized_topic_title
      discussion = []

      posts.each do |post|
        # skips drafted post
        next unless post[:workflow_state] == 'published'

        sanitized_text = ActionController::Base.helpers.strip_tags(post[:text])
        post_json = { role: post_creator_role(imported_forum.course, post), text: sanitized_text }
        discussion << post_json
      end

      existing_discussion = Course::Forum::Discussion.existing_discussion(discussion)
      if existing_discussion.exists?
        create_references_for_existing_discussion(existing_discussion.first, current_user)
      else
        create_new_discussion_and_reference(discussion, topic_title, current_user)
      end
    end
    save!
  end

  def ensure_forum_importing!
    ActiveRecord::Base.transaction(requires_new: true) do
      self.job_id ||= TrackableJob::Job.create!.id
      save!
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    raise e if e.is_a?(ActiveRecord::RecordInvalid) && e.record.errors[:job_id].empty?

    reload
    job_id
  end

  private

  def post_creator_role(course, post)
    course_user = course.course_users.find_by(user: post.creator)
    return 'System AI Response' unless course_user || !post[:is_ai_generated]
    return 'Not Found' unless course_user

    if course_user.teaching_staff?
      'Teaching Staff'
    elsif course_user.real_student?
      'Student'
    else
      'Not Found'
    end
  end

  def create_references_for_existing_discussion(existing_discussion, current_user)
    discussion_references.build(
      discussion: existing_discussion,
      creator: current_user,
      updater: current_user
    )
  end

  def create_new_discussion_and_reference(discussion, topic_title, current_user)
    discussion_json = { topic_title: topic_title,
                        discussion: discussion,
                        course_name: imported_forum.course.title }

    embedding = LANGCHAIN_OPENAI.embed(text: topic_title, model: 'text-embedding-ada-002').embedding
    discussion_references.build(
      creator: current_user,
      updater: current_user,
      discussion: Course::Forum::Discussion.new(
        discussion: discussion_json,
        name: Digest::SHA256.hexdigest(discussion.to_json),
        embedding: embedding
      )
    )
  end
end
