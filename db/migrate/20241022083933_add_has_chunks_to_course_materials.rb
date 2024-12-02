class AddHasChunksToCourseMaterials < ActiveRecord::Migration[7.2]
  def change
    add_column :course_materials, :has_chunks, :boolean, default: false, null: false
  end
end
