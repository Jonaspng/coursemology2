# frozen_string_literal: true
class Course::Material::TextChunkJob < ApplicationJob
  include TrackableJob
  queue_as :default

  protected

  def perform_tracked(material)
    material.build_text_chunks
    material.finish_chunking!
    material.save!
  end
end
