class Booking < ApplicationRecord
  SLOT_DURATION = 15.minutes
  AVAILABILITY_START_HOUR = 10
  AVAILABILITY_END_HOUR = 18
  HOST_TIMEZONE = "Europe/Lisbon"
  SLOT_TIMES = %w[10:00 10:30 11:00 14:30 15:00 16:00].freeze

  enum :status, {
    pending: 0,
    confirmed: 1,
    cancelled: 2
  }

  before_validation :generate_confirmation_token, on: :create
  before_validation :set_ends_at, on: :create

  validates :guest_name, presence: true
  validates :guest_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :starts_at, :ends_at, :timezone, :confirmation_token, presence: true
  validates :confirmation_token, uniqueness: true
  validate :starts_at_must_be_in_future, on: :create
  validate :starts_at_must_be_within_availability_hours, on: :create
  validate :no_overlapping_bookings, on: :create

  scope :active, -> { where(status: [:pending, :confirmed]) }
  scope :on_date, ->(date) {
    date = date.in_time_zone(HOST_TIMEZONE)
    where(starts_at: date.beginning_of_day..date.end_of_day)
  }

  # Horários ainda livres num dia, no fuso do anfitrião. Exclui slots já
  # reservados (pending/confirmed) e slots no passado.
  def self.available_slots_on(date)
    zone = Time.find_zone!(HOST_TIMEZONE)

    SLOT_TIMES.filter_map do |time|
      starts_at = zone.parse("#{date.iso8601} #{time}")
      next if starts_at <= Time.current

      ends_at = starts_at + SLOT_DURATION
      taken = active.where("starts_at < ? AND ends_at > ?", ends_at, starts_at).exists?
      time unless taken
    end
  end

  def confirm!
    update(status: :confirmed, confirmed_at: Time.current)
  end

  def cancel!
    update(status: :cancelled, cancelled_at: Time.current)
  end

  def display_date
    starts_at.in_time_zone(timezone).strftime("%A, %d %B %Y")
  end

  def display_time_range
    start_time = starts_at.in_time_zone(timezone).strftime("%H:%M")
    end_time = ends_at.in_time_zone(timezone).strftime("%H:%M")
    "#{start_time} - #{end_time}"
  end

  def host_display_time_range
    start_time = starts_at.in_time_zone(HOST_TIMEZONE).strftime("%H:%M")
    end_time = ends_at.in_time_zone(HOST_TIMEZONE).strftime("%H:%M")
    "#{start_time} - #{end_time} (Lisboa)"
  end

  private

  def generate_confirmation_token
    self.confirmation_token ||= SecureRandom.urlsafe_base64(24)
  end

  def set_ends_at
    self.ends_at ||= starts_at + SLOT_DURATION if starts_at.present?
  end

  def starts_at_must_be_in_future
    return unless starts_at.present?

    errors.add(:starts_at, "tem de ser no futuro") if starts_at <= Time.current
  end

  def starts_at_must_be_within_availability_hours
    return unless starts_at.present?

    lisbon_time = starts_at.in_time_zone(HOST_TIMEZONE)
    unless lisbon_time.hour >= AVAILABILITY_START_HOUR && lisbon_time.hour < AVAILABILITY_END_HOUR
      errors.add(:starts_at, "tem de ser entre #{AVAILABILITY_START_HOUR}:00 e #{AVAILABILITY_END_HOUR}:00")
    end
  end

  def no_overlapping_bookings
    return unless starts_at.present? && ends_at.present?

    overlapping = Booking.active.where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
    errors.add(:starts_at, "já está reservado") if overlapping.exists?
  end
end
