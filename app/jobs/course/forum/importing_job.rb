# frozen_string_literal: true
class Course::Forum::ImportingJob < ApplicationJob
  include TrackableJob
  queue_as :lowest

  protected

  def perform_tracked(forum_import_ids, current_user)
    forum_imports = Course::Forum::Import.where(id: forum_import_ids)
    ActiveRecord::Base.transaction do
      # to immediately update workflow state for frontend tracking
      forum_imports.update_all(workflow_state: 'importing')
    end
    ActiveRecord::Base.transaction do
      forum_imports.each do |forum_import|
        forum_import.build_discussions!(current_user)
      end
      forum_imports.update_all(workflow_state: 'imported')
    end
  end
end
