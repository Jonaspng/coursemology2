class UpdateCourseMaterials < ActiveRecord::Migration[7.2]
  def change
    remove_column :course_material_text_chunks, :creator_id, :integer
    remove_column :course_material_text_chunks, :updater_id, :integer
    add_column :course_material_text_chunks, :chunker_id, :integer
    add_foreign_key :course_material_text_chunks, :users, column: :chunker_id, name: 'fk_course_materials_chunker_id'
  end
end
