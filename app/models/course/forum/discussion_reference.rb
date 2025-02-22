# frozen_string_literal: true
class Course::Forum::DiscussionReference < ApplicationRecord
  validates :creator, presence: true
  validates :updater, presence: true
  validates :discussion, presence: true
  belongs_to :discussion, inverse_of: :discussion_references,
                          class_name: 'Course::Forum::Discussion'
  belongs_to :forum_import, inverse_of: :discussion_references, class_name: 'Course::Forum::Import'
end
