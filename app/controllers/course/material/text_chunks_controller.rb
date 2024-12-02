# frozen_string_literal: true
class Course::Material::TextChunksController < Course::Material::Controller
  load_and_authorize_resource :material, through: :folder, class: 'Course::Material'
  load_and_authorize_resource :text_chunk, through: :material, class: 'Course::Material::TextChunk'

  def create
    @text_chunk = @material.text_chunks.new(text_chunk_params)
    if @text_chunk.save
      render json: { id: @text_chunk.id, content: @text_chunk.content, createdAt: @text_chunk.created_at }, status: :ok
    else
      render json: { errors: @text_chunk.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def destroy
    if @text_chunk.destroy
      head :no_content
    else
      render json: { errors: @text_chunk.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def text_chunk_params
    params.require(:text_chunk).permit(:content, :embedding, :creator, :updater)
  end
end
