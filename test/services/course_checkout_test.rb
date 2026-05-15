require "test_helper"
require "ostruct"

class CourseCheckoutTest < ActiveSupport::TestCase
  test "mock checkout can be disabled explicitly" do
    with_env("ALLOW_MOCK_COURSE_CHECKOUT" => "false", "STRIPE_SECRET_KEY" => nil, "STRIPE_PRICE_FUNDAMENTOS_IA" => nil) do
      assert_not CourseCheckout.mock_checkout_enabled?
      assert_raises(CourseCheckout::MissingConfigurationError) do
        CourseCheckout.create_session(return_url: "https://ipiia.pt/checkout/success", cancel_url: "https://ipiia.pt/checkout/cancel")
      end
    end
  end

  test "does not fulfill checkout sessions that are not paid" do
    assert_no_difference "Learner.count" do
      assert_nil CourseCheckout.fulfill_checkout_session!(stripe_session(payment_status: "unpaid"))
    end
  end

  test "fulfills paid checkout session and enqueues access email" do
    session = stripe_session(payment_status: "paid")

    assert_enqueued_emails 1 do
      enrollment = CourseCheckout.fulfill_checkout_session!(session)

      assert enrollment.active?
      assert_equal "ana@example.com", enrollment.learner.email
      assert_equal "cs_test_123", enrollment.stripe_checkout_session_id
      assert_equal 3999, enrollment.amount_cents
    end
  end

  private

  def stripe_session(payment_status:)
    OpenStruct.new(
      id: "cs_test_123",
      payment_status: payment_status,
      metadata: { "course_slug" => CourseCatalog.fundamentos.slug },
      customer_details: OpenStruct.new(email: "ana@example.com", name: "Ana Silva"),
      customer_email: nil,
      customer: "cus_test_123",
      payment_intent: "pi_test_123",
      amount_total: 3999,
      currency: "eur"
    )
  end

  def with_env(values)
    previous = values.each_with_object({}) do |(key, value), memo|
      memo[key] = ENV[key]
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end

    yield
  ensure
    previous.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end
end
