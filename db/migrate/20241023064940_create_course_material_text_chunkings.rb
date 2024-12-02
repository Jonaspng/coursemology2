class CreateCourseMaterialTextChunkings < ActiveRecord::Migration[7.2]
  def change
    create_table :course_material_text_chunkings, id: :serial do |t|
      t.integer :actable_id
      t.string :actable_type, limit: 255
      t.integer :material_id, null: false
      t.uuid :job_id
      t.json :result
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      # Add indexes
      t.index [:actable_id, :actable_type], name: "index_course_material_text_chunkings_on_actable", unique: true
      t.index :material_id, name: "index_course_material_text_chunkings_on_material_id", unique: true
      t.index :job_id, name: "index_course_material_text_chunkings_on_job_id", unique: true
    end

    # Add foreign keys
    add_foreign_key :course_material_text_chunkings, :course_materials, column: :material_id, name: "fk_course_material_text_chunkings_answer_id"
    add_foreign_key :course_material_text_chunkings, :jobs, name: "fk_course_material_text_chunkings_job_id", on_delete: :nullify
  end
end
