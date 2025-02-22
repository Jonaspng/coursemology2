class CreateCourseForumDiscussionReferences < ActiveRecord::Migration[7.2]
  def change
    create_table :course_forum_discussion_references do |t|
      t.datetime :created_at, precision: nil, null: false
      t.datetime :updated_at, precision: nil, null: false
      t.references :forum_import, 
                    null: false, 
                    foreign_key: { to_table: :course_forum_imports, name: "fk_course_forum_discussion_references_forum_import_id" }, 
                    index: { name: "fk__course_forum_discussion_references_forum_import_id" }
      t.references :discussion, 
                    null: false, 
                    foreign_key: { to_table: :course_forum_discussions, name: "fk_course_forum_discussion_references_discussion_id" }, 
                    index: { name: "fk__course_forum_discussion_references_discussion_id" }
      t.references :creator, 
                    null: false,
                    foreign_key: { to_table: :users, name: "fk_course_forum_discussion_references_creator_id" },
                    index: { name: "fk__course_forum_discussion_references_creator_id" }
      t.references :updater, 
                    null: false,
                    foreign_key: { to_table: :users, name: "fk_course_forum_discussion_references_updater_id" },
                    index: { name: "fk__course_forum_discussion_references_updater_id" }
    end
  end
end
