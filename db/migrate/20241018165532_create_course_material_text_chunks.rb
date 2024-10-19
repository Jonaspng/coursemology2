class CreateCourseMaterialTextChunks < ActiveRecord::Migration[7.2]
  def change
    # Ensure pgvector extension is enabled
    enable_extension "vector" unless extension_enabled?("vector")
    create_table :course_material_text_chunks, id: :serial, force: :cascade do |t|

      # Main association
      t.belongs_to :course_material, null: false

      t.text :content, null: false
      t.vector :embedding, limit: 1536, null: false

      # Foreign Keys
      t.references :creator, foreign_key: { to_table: :users }
      t.references :updater, foreign_key: { to_table: :users }
      t.references :course, foreign_key: { to_table: :courses }

      # Indexes
      t.index :embedding, name: "index_on_course_material_text_chunk_embedding", opclass: :vector_cosine_ops, using: :hnsw
    end
  end
end
