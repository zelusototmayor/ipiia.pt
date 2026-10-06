require "test_helper"

class AnalyticsBookingConfirmationTest < ActionDispatch::IntegrationTest
  test "saved booking requests one-shot marker only after explicit opt-in" do
    assert_difference("Booking.count", 1) { post "/bookings", params: booking_params.merge(analytics_consented: "true") }
    assert_response :redirect
    follow_redirect!
    assert_select "meta[name='ipiia-booking-confirmed']", count: 1
    assert_no_match(/MIXPANEL_TOKEN|api-eu\.mixpanel\.com/, response.body)
    get response.request.path
    assert_select "meta[name='ipiia-booking-confirmed']", count: 0
  end

  test "saved booking without opt-in and bare persisted URL emit no marker" do
    post "/bookings", params: booking_params
    assert_response :redirect
    target = response.location
    follow_redirect!
    assert_select "meta[name='ipiia-booking-confirmed']", count: 0
    get URI(target).path
    assert_select "meta[name='ipiia-booking-confirmed']", count: 0
  end

  test "invalid booking with opt-in never creates completion marker" do
    assert_no_difference("Booking.count") do
      post "/bookings", params: booking_params.merge(booking: booking_params[:booking].merge(guest_email: "invalid"), analytics_consented: "true")
    end
    follow_redirect!
    assert_select "meta[name='ipiia-booking-confirmed']", count: 0
  end

  test "public pages keep copy, importmap local only, no consent or provider snippet" do
    get "/contacto.html"
    assert_response :success
    assert_select "#contact-form", count: 1
    assert_select "meta[name='ipiia-booking-confirmed']", count: 0
    assert_select "script[src*='mixpanel']", count: 0
    assert_select "script[type='importmap']", text: /analytics\/index/
    assert_no_match(/Aceitar analytics|org_analytics_attribution_v1|MIXPANEL_TOKEN/, response.body)
  end

  private

  def booking_params
    {
      booking: {
        guest_name: "Synthetic Canary", guest_email: "canary@example.test",
        guest_company: "Synthetic", date: 7.days.from_now.in_time_zone("Europe/Lisbon").to_date.iso8601,
        time: "11:00", timezone: "Europe/Lisbon", topic: "Test", notes: "Synthetic free text"
      }
    }
  end
end
