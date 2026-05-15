class GoogleCalendarSyncJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking
    return if booking.cancelled? || booking.google_event_id.present?

    service = GoogleCalendarService.new
    return unless service.configured?

    result = service.create_event(booking)
    return unless result

    booking.update!(
      google_event_id: result[:event_id],
      google_meet_link: result[:meet_link],
      status: :confirmed,
      confirmed_at: Time.current
    )

    BookingMailer.confirmed_with_meet_link(booking).deliver_later
  end
end
