# frozen_string_literal: true
class Course::Material::TextChunking < ApplicationRecord
  actable optional: true

  validates :actable_type, length: { maximum: 255 }, allow_nil: true
  validates :material, presence: true
  validates :material_id, uniqueness: { if: :material_id_changed? }, allow_nil: true
  validates :job_id, uniqueness: { if: :job_id_changed? }, allow_nil: true
  validates :actable_type, uniqueness: { scope: [:actable_id], allow_nil: true,
                                         if: -> { actable_id? && actable_type_changed? } }
  validates :actable_id, uniqueness: { scope: [:actable_type], allow_nil: true,
                                       if: -> { actable_type? && actable_id_changed? } }

  belongs_to :material, class_name: 'Course::Material', inverse_of: :text_chunking
  # @!attribute [r] job
  #   This might be null if the job has been cleared.
  belongs_to :job, class_name: 'TrackableJob::Job', inverse_of: nil, optional: true
end