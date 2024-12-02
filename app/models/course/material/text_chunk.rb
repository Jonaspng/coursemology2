# frozen_string_literal: true
class Course::Material::TextChunk < ApplicationRecord
  has_neighbors :embedding

  before_save :set_course_id

  belongs_to :material, inverse_of: :text_chunks, class_name: 'Course::Material',
                        foreign_key: :course_material_id, autosave: true
  belongs_to :course
  belongs_to :chunker, class_name: 'User', inverse_of: nil, optional: true

  validates :content, presence: true
  validates :embedding, presence: true
  validates :course_id, presence: true

  # def validate_unique_text_chunk_and_content
  #   if self.class.exists?(text_chunk_id: text_chunk_id, content: content)
  #     errors.add(:base, "The combination of TextChunk ID #{text_chunk_id} and Content has already been taken.")
  #   end
  # end

  def self.get_nearest_neighbours(query_embedding, file_name: nil)
    CourseMaterial.connection.execute('SET hnsw.ef_search = 100')
    nearest_items = if file_name
                      CourseMaterial.where(file_name: file_name).
                        nearest_neighbors(:embedding, query_embedding, distance: 'cosine').
                        first(5)
                    else
                      CourseMaterial.nearest_neighbors(:embedding, query_embedding, distance: 'cosine').
                        first(5)
                    end
    threshold = 0.4
    filtered_items = nearest_items.select { |item| item.neighbor_distance <= threshold }
    filtered_items.pluck(:data)
  end

  def set_course_id
    self.course_id = material.folder.course_id if material&.folder
  end
end
