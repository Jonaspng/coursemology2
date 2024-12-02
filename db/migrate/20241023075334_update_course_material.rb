class UpdateCourseMaterial < ActiveRecord::Migration[7.2]
  def change
    change_table :course_materials do |t|
      # Add new columns
      t.integer :actable_id
      t.string :actable_type, limit: 255
      t.string :workflow_state, limit: 255, null: false, default: "not_chunked"
      
      # Remove the chunk_status column
      t.remove :chunks_status
    end
  end
end
