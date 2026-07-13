class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :cancel]

  def create
    @booking = Booking.new(booking_params.merge(starts_at: starts_at, timezone: timezone))

    if @booking.save
      GoogleCalendarSyncJob.perform_later(@booking.id)
      BookingMailer.confirmation(@booking).deliver_later
      BookingMailer.host_notification(@booking).deliver_later

      redirect_to booking_path(@booking.confirmation_token), notice: "Intro call registada."
    else
      redirect_to page_path("book-call"), alert: @booking.errors.full_messages.to_sentence
    end
  end

  def show
  end

  def availability
    date = Date.iso8601(params[:date].to_s)
    render json: { slots: Booking.available_slots_on(date) }
  rescue Date::Error
    render json: { errors: [ "Data inválida" ] }, status: :unprocessable_entity
  end

  def cancel
    if @booking.pending? || @booking.confirmed?
      @booking.cancel!
      GoogleCalendarCancelJob.perform_later(@booking.google_event_id) if @booking.google_event_id.present?
      BookingMailer.cancellation(@booking).deliver_later
      redirect_to page_path("book-call"), notice: "A reserva foi cancelada."
    else
      redirect_to booking_path(@booking.confirmation_token), alert: "Esta reserva já não pode ser cancelada."
    end
  end

  private

  def set_booking
    @booking = Booking.find_by!(confirmation_token: params[:confirmation_token])
  end

  def booking_params
    params.require(:booking).permit(:guest_name, :guest_email, :guest_company, :topic, :notes)
  end

  def starts_at
    Time.find_zone!(Booking::HOST_TIMEZONE).parse("#{params.dig(:booking, :date)} #{params.dig(:booking, :time)}")
  end

  def timezone
    params.dig(:booking, :timezone).presence || Booking::HOST_TIMEZONE
  end
end
