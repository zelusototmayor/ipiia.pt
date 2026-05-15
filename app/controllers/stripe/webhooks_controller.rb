module Stripe
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def webhook
      return head :service_unavailable if Rails.env.production? && ENV["STRIPE_WEBHOOK_SECRET"].blank?

      event = build_event

      if event.type == "checkout.session.completed"
        CourseCheckout.fulfill_checkout_session!(event.data.object)
      end

      head :ok
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      head :bad_request
    end

    private

    def build_event
      payload = request.body.read
      secret = ENV["STRIPE_WEBHOOK_SECRET"]
      return Stripe::Event.construct_from(JSON.parse(payload)) if secret.blank?

      Stripe::Webhook.construct_event(payload, request.env["HTTP_STRIPE_SIGNATURE"], secret)
    end
  end
end
