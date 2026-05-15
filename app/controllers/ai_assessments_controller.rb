class AiAssessmentsController < ApplicationController
  protect_from_forgery with: :exception

  def create
    scoring = AiReadinessTest.score(assessment_params[:answers] || {})
    assessment = AiAssessment.new(
      name: assessment_params[:name],
      email: assessment_params[:email],
      role: assessment_params[:role],
      company: assessment_params[:company],
      use_case: assessment_params[:use_case],
      answers_json: scoring[:answers].to_json,
      dimension_scores_json: scoring[:dimension_scores].to_json,
      signals_json: scoring[:signals].to_json,
      priorities_json: scoring[:priorities].to_json,
      strengths_json: scoring[:strengths].to_json,
      overall_score: scoring[:overall_score],
      profile_key: scoring[:profile_key],
      profile_title: scoring[:profile_title],
      profile_summary: scoring[:profile_summary],
      recommended_path: scoring[:recommended_path]
    )

    if assessment.save
      AiAssessmentMailer.results(assessment).deliver_later
      AiAssessmentMailer.host_notification(assessment).deliver_later
      render json: {
        ok: true,
        message: "Diagnóstico registado. Enviámos o relatório para o email indicado.",
        profile: assessment.profile_title
      }, status: :created
    else
      render json: { ok: false, errors: assessment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def assessment_params
    params.require(:ai_assessment).permit(
      :name,
      :email,
      :role,
      :company,
      :use_case,
      answers: {}
    )
  end
end
