class CourseSessionsController < ApplicationController
  def new
    redirect_to course_dashboard_path if current_learner&.enrolled_in?(CourseCatalog.fundamentos.slug)
  end

  def create
    learner = Learner.find_by(email: params[:email].to_s.strip.downcase)
    enrollment = learner&.course_enrollments&.active&.find_by(course_slug: CourseCatalog.fundamentos.slug)

    CourseMailer.access_link(enrollment).deliver_later if enrollment.present?
    redirect_to new_course_session_path, notice: "Se existir uma matrícula com esse email, enviámos um link de acesso."
  end

  def magic
    learner = Learner.find_signed!(params[:token], purpose: :course_login)
    session[:learner_id] = learner.id

    redirect_to course_dashboard_path, notice: "Sessão iniciada. Pode continuar o curso."
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_course_session_path, alert: "Este link expirou. Peça um novo link de acesso."
  end

  def destroy
    session.delete(:learner_id)
    redirect_to root_path, notice: "Sessão terminada."
  end
end
