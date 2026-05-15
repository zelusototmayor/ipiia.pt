class CheckoutsController < ApplicationController
  def create
    session = CourseCheckout.create_session(
      return_url: success_checkout_url,
      cancel_url: cancel_checkout_url,
      learner_email: current_learner&.email
    )

    redirect_to session.url, allow_other_host: true
  rescue KeyError, CourseCheckout::MissingConfigurationError
    redirect_to page_path("curso-fundamentos"), alert: "O checkout ainda não está configurado. Falta ligar o preço Stripe do curso."
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe checkout error: #{e.message}"
    redirect_to page_path("curso-fundamentos"), alert: "Não foi possível iniciar o checkout. Tente novamente dentro de instantes."
  end

  def success
    if params[:mock_checkout].present?
      return redirect_to(page_path("curso-fundamentos"), alert: "O checkout de teste está desativado.") unless CourseCheckout.mock_checkout_enabled?

      return fulfill_mock_checkout if params[:email].present?

      render :mock_success
      return
    end

    if params[:session_id].present? && CourseCheckout.stripe_configured?
      Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
      checkout_session = Stripe::Checkout::Session.retrieve(
        id: params[:session_id],
        expand: [ "customer_details" ]
      )
      @enrollment = CourseCheckout.fulfill_checkout_session!(checkout_session)
      return redirect_to(new_course_session_path, alert: "Ainda estamos a confirmar o pagamento. Peça o link de acesso com o email usado no checkout.") if @enrollment.blank?

      session[:learner_id] = @enrollment.learner_id if @enrollment.present?
    end

    render :success
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe success sync error: #{e.message}"
    redirect_to new_course_session_path, alert: "Pagamento recebido. Peça o link de acesso com o mesmo email usado no checkout."
  end

  def cancel
    redirect_to page_path("curso-fundamentos"), alert: "Checkout cancelado. Pode retomar a compra quando quiser."
  end

  private

  def fulfill_mock_checkout
    @enrollment = CourseCheckout.fulfill_mock_checkout!(
      email: params[:email],
      name: params[:name].presence || params[:email].to_s.split("@").first
    )
    session[:learner_id] = @enrollment.learner_id
    render :success
  end
end
