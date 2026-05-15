class Learner < ApplicationRecord
  has_many :course_enrollments, dependent: :destroy

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.find_or_initialize_from_checkout(email:, name:, company: nil, role: nil, stripe_customer_id: nil)
    learner = find_or_initialize_by(email: email.to_s.strip.downcase)
    learner.name = name.presence || learner.name || email.to_s.split("@").first
    learner.company = company if company.present?
    learner.role = role if role.present?
    learner.stripe_customer_id = stripe_customer_id if stripe_customer_id.present?
    learner
  end

  def enrolled_in?(course_slug)
    course_enrollments.active.exists?(course_slug: course_slug)
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
