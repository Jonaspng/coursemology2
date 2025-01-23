# frozen_string_literal: true
class RagWise::RagWorkflowService
  def initialize(course, evaluation_service, character)
    @client = LANGCHAIN_OPENAI
    @evaluation = evaluation_service

    course_materials_tool = RagWise::Tools::CourseMaterialsTool.new(course, @evaluation)

    @assistant = Langchain::Assistant.new(
      llm: @client,
      instructions: Langchain::Prompt.
                    load_from_path(file_path: 'app/services/rag_wise/prompts/forum_assistant_system_prompt.json').
                    format(character: character),
      tools: [course_materials_tool]
    )
  end

  def get_assistant_response(post, topic)
    query_payload = "query title: #{topic.title} query text: #{post.text} "
    first_image_data = first_image(post)
    if first_image_data
      @assistant.add_message_and_run!(content: query_payload,
                                      image_url: "data:image/jpeg;base64,#{first_image(post)}")
    else
      @assistant.add_message_and_run!(content: query_payload)
    end
    response = @assistant.messages.last.content

    @evaluation.answer = response
    response
  end

  private

  # for multiple images, currently not in use
  def images_captions(post)
    images_captions = ''
    llm_service = RagWise::LlmService.new
    post.attachments.each do |attachment|
      images_captions += "#{llm_service.get_image_caption(attachment)} "
    end
    images_captions
  end

  def first_image(post)
    # Check if the post has attachments and the first one is present
    return unless post.attachments.any?

    first_attachment = post.attachments.first
    # Encode the file contents to Base64
    Base64.strict_encode64(File.read(first_attachment.path))
  end
end
