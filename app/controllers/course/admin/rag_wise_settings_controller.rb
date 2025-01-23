# frozen_string_literal: true
class Course::Admin::RagWiseSettingsController < Course::Admin::Controller
  def edit
    respond_to do |format|
      format.json
    end
  end

  def update
    if @settings.update(rag_wise_settings_params) && current_course.save
      render 'edit'
    else
      render json: { errors: @settings.errors }, status: :bad_request
    end
  end

  def materials
    @materials = current_course.materials.
                 select { |folder| folder.name.match?(/\.(pdf|txt)\z/i) }
  end

  def folders
    @folders = current_course.material_folders
  end

  private

  def rag_wise_settings_params
    params.require(:settings_rag_wise_component).permit(:response_workflow, :roleplay)
  end

  def component
    current_component_host[:course_rag_wise_component]
  end
end
