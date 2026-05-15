require "google/apis/calendar_v3"
require "googleauth"

class GoogleCalendarService
  CALENDAR_SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  APPLICATION_NAME = "IPIIA Booking System"

  def initialize
    @host_email = credentials_config[:host_email]
    @calendar_id = @host_email || "primary"
    @service = build_service
  end

  def create_event(booking)
    return nil unless configured?

    event = Google::Apis::CalendarV3::Event.new(
      summary: "IPIIA intro call with #{booking.guest_name}",
      description: event_description(booking),
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: booking.starts_at.iso8601,
        time_zone: Booking::HOST_TIMEZONE
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: booking.ends_at.iso8601,
        time_zone: Booking::HOST_TIMEZONE
      ),
      attendees: [
        Google::Apis::CalendarV3::EventAttendee.new(
          email: booking.guest_email,
          display_name: booking.guest_name,
          response_status: "needsAction"
        ),
        Google::Apis::CalendarV3::EventAttendee.new(
          email: "zelu@zelusottomayor.com",
          response_status: "accepted"
        )
      ],
      reminders: Google::Apis::CalendarV3::Event::Reminders.new(
        use_default: false,
        overrides: [
          Google::Apis::CalendarV3::EventReminder.new(reminder_method: "email", minutes: 60),
          Google::Apis::CalendarV3::EventReminder.new(reminder_method: "popup", minutes: 15)
        ]
      )
    )

    begin
      event.conference_data = Google::Apis::CalendarV3::ConferenceData.new(
        create_request: Google::Apis::CalendarV3::CreateConferenceRequest.new(
          request_id: SecureRandom.uuid,
          conference_solution_key: Google::Apis::CalendarV3::ConferenceSolutionKey.new(type: "hangoutsMeet")
        )
      )

      created_event = @service.insert_event(
        @calendar_id,
        event,
        conference_data_version: 1,
        send_updates: "all"
      )
    rescue Google::Apis::ClientError => e
      raise e unless e.message.include?("Invalid conference type")

      event.conference_data = nil
      created_event = @service.insert_event(@calendar_id, event, send_updates: "all")
    end

    {
      event_id: created_event.id,
      meet_link: created_event.hangout_link || extract_meet_link(created_event)
    }
  rescue Google::Apis::Error => e
    Rails.logger.error "Google Calendar API error (create_event): #{e.message}"
    nil
  end

  def cancel_event(event_id)
    return false unless configured? && event_id.present?

    @service.delete_event(@calendar_id, event_id, send_updates: "all")
    true
  rescue Google::Apis::Error => e
    Rails.logger.error "Google Calendar API error (cancel_event): #{e.message}"
    false
  end

  def configured?
    credentials_config[:service_account_key].present? && @host_email.present?
  end

  private

  def build_service
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize if configured?
    service
  end

  def authorize
    key_data = credentials_config[:service_account_key]
    key_json = key_data.is_a?(Hash) ? key_data.to_json : key_data

    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(key_json),
      scope: CALENDAR_SCOPE
    )
    authorizer.sub = @host_email if @host_email.present?
    authorizer.fetch_access_token!
    authorizer
  rescue StandardError => e
    Rails.logger.error "Google Auth error: #{e.message}"
    nil
  end

  def credentials_config
    @credentials_config ||= begin
      if Rails.application.credentials.google.present?
        Rails.application.credentials.google.to_h.with_indifferent_access
      else
        {}
      end
    end
  end

  def event_description(booking)
    parts = ["15-minute IPIIA intro call."]
    parts << "Company: #{booking.guest_company}" if booking.guest_company.present?
    parts << "Topic: #{booking.topic}" if booking.topic.present?
    parts << "Notes: #{booking.notes}" if booking.notes.present?
    parts << "Guest timezone: #{booking.timezone}"
    parts.join("\n\n")
  end

  def extract_meet_link(event)
    video_entry = event.conference_data&.entry_points&.find { |entry| entry.entry_point_type == "video" }
    video_entry&.uri
  end
end
