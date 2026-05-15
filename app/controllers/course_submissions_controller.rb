class CourseSubmissionsController < ApplicationController
  before_action :require_learner!
  before_action :set_enrollment

  def new
    @page_title = "Submissão prática — #{CourseCatalog.fundamentos.title}"
    @submission = @enrollment.latest_submission || @enrollment.course_submissions.new
  end

  def create
    @submission = @enrollment.course_submissions.create!(workflow_text: params[:workflow_text])
    result = WorkflowEvaluator.evaluate(@submission.workflow_text)
    @submission.update!(
      status: result.fetch("approved") ? "approved" : "needs_revision",
      ai_score: result.fetch("score"),
      ai_feedback_json: result.to_json,
      ai_provider: result.fetch("provider"),
      evaluated_at: Time.current
    )
    had_certificate = @enrollment.certificate.present?
    certificate = @enrollment.issue_certificate_if_ready!

    if certificate.present?
      CourseMailer.certificate_issued(certificate).deliver_later unless had_certificate
      redirect_to certificate_path(certificate.code), notice: "Workflow aprovado e certificado emitido."
    else
      redirect_to new_course_submission_path, notice: submission_notice(@submission)
    end
  rescue ActiveRecord::RecordInvalid => e
    @submission ||= @enrollment.course_submissions.new(workflow_text: params[:workflow_text])
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end

  private

  def set_enrollment
    @enrollment = current_learner.course_enrollments.active.find_by!(course_slug: CourseCatalog.fundamentos.slug)
  end

  def submission_notice(submission)
    return "Workflow aprovado. Complete o quiz com pelo menos #{CourseEnrollment::CERTIFICATE_THRESHOLD}% para emitir o certificado." if submission.approved?

    "Workflow avaliado com #{submission.ai_score}%. Reveja o feedback e submeta uma nova versão."
  end
end
