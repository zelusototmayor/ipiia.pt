class GoogleCalendarCancelJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    GoogleCalendarService.new.cancel_event(event_id)
  end
end
