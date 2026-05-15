require "ostruct"

class CourseCheckout
  class MissingConfigurationError < StandardError; end

  COURSE_SLUG = CourseCatalog.fundamentos.slug

  def self.create_session(return_url:, cancel_url:, learner_email: nil)
    if stripe_configured?
      Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
      Stripe::Checkout::Session.create(
        mode: "payment",
        customer_email: learner_email.presence,
        line_items: [
          {
            price: ENV.fetch("STRIPE_PRICE_FUNDAMENTOS_IA"),
            quantity: 1
          }
        ],
        metadata: {
          course_slug: COURSE_SLUG
        },
        success_url: "#{return_url}?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: cancel_url,
        allow_promotion_codes: true,
        automatic_tax: { enabled: ENV.fetch("STRIPE_AUTOMATIC_TAX", "false") == "true" }
      )
    elsif mock_checkout_enabled?
      OpenStruct.new(url: "#{return_url}?mock_checkout=1&course_slug=#{COURSE_SLUG}", id: "mock_#{SecureRandom.hex(8)}")
    else
      raise MissingConfigurationError, "Stripe checkout is not configured"
    end
  end

  def self.stripe_configured?
    ENV["STRIPE_SECRET_KEY"].present? && ENV["STRIPE_PRICE_FUNDAMENTOS_IA"].present?
  end

  def self.mock_checkout_enabled?
    default = Rails.env.development? || Rails.env.test? ? "true" : "false"
    ENV.fetch("ALLOW_MOCK_COURSE_CHECKOUT", default) == "true"
  end

  def self.fulfill_checkout_session!(session)
    return unless session.payment_status == "paid"

    metadata = session.metadata.respond_to?(:to_h) ? session.metadata.to_h : {}
    course_slug = metadata["course_slug"] || COURSE_SLUG
    email = session.customer_details&.email || session.customer_email
    raise MissingConfigurationError, "Checkout session has no customer email" if email.blank?

    name = session.customer_details&.name || email.to_s.split("@").first

    learner = Learner.find_or_initialize_from_checkout(
      email: email,
      name: name,
      stripe_customer_id: session.customer
    )
    learner.save!

    enrollment = learner.course_enrollments.find_or_initialize_by(course_slug: course_slug)
    should_send_access = enrollment.new_record? || enrollment.purchased_at.blank?
    enrollment.assign_attributes(
      status: :active,
      stripe_checkout_session_id: session.id,
      stripe_payment_intent_id: session.payment_intent,
      stripe_customer_id: session.customer,
      amount_cents: session.amount_total || CourseCatalog.find(course_slug).price_cents,
      currency: session.currency || "eur",
      purchased_at: Time.current
    )
    enrollment.save!

    CourseMailer.access_link(enrollment).deliver_later if should_send_access
    enrollment
  end

  def self.fulfill_mock_checkout!(email:, name:)
    raise MissingConfigurationError, "Mock checkout is disabled" unless mock_checkout_enabled?

    learner = Learner.find_or_initialize_from_checkout(email: email, name: name)
    learner.save!

    enrollment = learner.course_enrollments.find_or_initialize_by(course_slug: COURSE_SLUG)
    enrollment.assign_attributes(status: :active, purchased_at: Time.current)
    enrollment.save!
    CourseMailer.access_link(enrollment).deliver_later
    enrollment
  end
end
