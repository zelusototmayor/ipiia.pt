class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_learner

  private

  def current_learner
    @current_learner ||= Learner.find_by(id: session[:learner_id]) if session[:learner_id].present?
  end

  def require_learner!
    return if current_learner.present?

    redirect_to new_course_session_path, alert: "Envie um link de acesso para continuar o curso."
  end
end
