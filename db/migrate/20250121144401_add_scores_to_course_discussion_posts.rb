class AddScoresToCourseDiscussionPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :course_discussion_posts, :faithfulness_score, :float, null: false, default: 0.0
    add_column :course_discussion_posts, :answer_relevance_score, :float, null: false, default: 0.0
  end
end
