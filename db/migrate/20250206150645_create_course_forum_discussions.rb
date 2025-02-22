class CreateCourseForumDiscussions < ActiveRecord::Migration[7.2]
  def change
    create_table :course_forum_discussions do |t|
      t.vector :embedding, limit: 1536, null: false
      t.jsonb :discussion, null:false, default: {}
      t.string :name, null: false
      # Indexes
      t.index :embedding, 
              name: "index_course_forum_discussions_on_embedding", 
              opclass: :vector_cosine_ops, 
              using: :hnsw
      t.index :name, name: "index_course_forum_discussions_on_name"
    end
  end
end
