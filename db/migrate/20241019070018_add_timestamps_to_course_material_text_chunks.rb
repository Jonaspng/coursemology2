class AddTimestampsToCourseMaterialTextChunks < ActiveRecord::Migration[7.2]
  def change
    change_table :course_material_text_chunks, bulk: true do |t|
      t.datetime :created_at, precision: nil, null: false
      t.datetime :updated_at, precision: nil, null: false
    end
  end
end
