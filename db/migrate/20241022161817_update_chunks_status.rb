class UpdateChunksStatus < ActiveRecord::Migration[7.2]
  def change
    remove_column :course_materials, :has_chunks, :boolean
    add_column :course_materials, :chunks_status, :integer, default: 0
  end
end
