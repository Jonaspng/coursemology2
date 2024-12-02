class AddUniqueIndexToTextChunks < ActiveRecord::Migration[7.2]
  def change
    add_index :course_material_text_chunks, [:course_material_id, :content], unique: true, name: 'index_text_chunks_on_text_chunk_id_and_content'
  end
end
