# frozen_string_literal: true
class Course::Material::TextChunkJob < ApplicationJob
  include TrackableJob
  queue_as :default

  protected

  def perform_tracked(material_ids, current_user)
    materials = Course::Material.where(id: material_ids)
    ActiveRecord::Base.transaction do
      # to immediately update workflow state for frontend tracking
      materials.update_all(workflow_state: 'chunking')
    end
    ActiveRecord::Base.transaction do
      materials.each do |material|
        material.build_text_chunks(current_user)
      end
      materials.update_all(workflow_state: 'chunked')
    end
  end
end
