class RemoveActableColumnsAndIndexesFromCourseMaterialTextChunkings < ActiveRecord::Migration[7.2]
  def change
    # Remove the index on actable_id and actable_type
    remove_index :course_material_text_chunkings, name: 'index_course_material_text_chunkings_on_actable' if index_exists?(:course_material_text_chunkings, [:actable_id, :actable_type])

    # Remove the actable_id, actable_type, and result columns
    remove_column :course_material_text_chunkings, :actable_id
    remove_column :course_material_text_chunkings, :actable_type
    remove_column :course_material_text_chunkings, :result
    remove_column :course_materials, :actable_id
    remove_column :course_materials, :actable_type
  end
end
