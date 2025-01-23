# frozen_string_literal: true
module Course::Forum::AutoAnsweringConcern
  extend ActiveSupport::Concern

  def auto_answer_action(is_new_reply)
    return unless current_course.component_enabled?(Course::RagWiseComponent)

    settings = rag_settings
    # ensures that when manually generating new reply it will always draft
    settings[:response_workflow] = '0' if is_new_reply

    system ||= User.find(User::SYSTEM_USER_ID)
    raise 'No system user. Did you run rake db:seed?' unless system

    target_post = is_new_reply ? @post : @topic.posts.first
    target_post.rag_auto_answer!(@topic, system, nil, settings)
  end

  def publish_post_action
    return false unless current_course.component_enabled?(Course::RagWiseComponent)

    @post.publish_post(@topic, current_user, current_course_user)
  end

  def last_rag_auto_answering_job
    return head(:bad_request) unless current_course.component_enabled?(Course::RagWiseComponent)

    job = @post.rag_auto_answering&.job
    (job&.status == 'submitted') ? job : nil
  end

  def rag_settings
    rag_component = current_component_host[:course_rag_wise_component].settings
    {
      response_workflow: rag_component.response_workflow,
      roleplay: rag_component.roleplay
    }
  end
end
