class CreateCourseForumImports < ActiveRecord::Migration[7.2]
  def change
    create_table :course_forum_imports do |t|
      t.datetime :created_at, precision: nil, null: false
      t.datetime :updated_at, precision: nil, null: false
      t.references :course, null: false, foreign_key: { to_table: :courses, name: "fk_ccourse_forum_imports_course_id" }, index: { name: "fk__course_forum_imports_course_id" }
      t.references :imported_forum, null: false, foreign_key: { to_table: :course_forums, name: "fk_course_forum_imports_imported_forum_id" }, index: { name: "fk__course_forum_imports_imported_forum_id" }
      t.string :workflow_state, limit: 255, null: false, default: "not_imported"
      t.references :job, type: :uuid, foreign_key: { to_table: :jobs, name: "fk_course_forum_importings_job_id", on_delete: :nullify }, index: { name: "fk__course_forum_importings_job_id" }
    end
  end
end
