class AddOriginalTextToCourseDiscussionPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :course_discussion_posts, :original_text, :string
  end
end