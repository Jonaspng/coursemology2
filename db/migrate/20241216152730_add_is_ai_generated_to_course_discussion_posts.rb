class AddIsAiGeneratedToCourseDiscussionPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :course_discussion_posts, :is_ai_generated, :boolean, default: false, null: false
  end
end
