class CourseEnrollment < ApplicationRecord
  CERTIFICATE_THRESHOLD = 65

  belongs_to :learner
  has_many :lesson_progresses, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy
  has_many :course_submissions, dependent: :destroy
  has_one :certificate, dependent: :destroy

  enum :status, { active: 0, refunded: 1, revoked: 2 }

  validates :course_slug, presence: true
  validates :course_slug, uniqueness: { scope: :learner_id }

  def course
    CourseCatalog.find(course_slug)
  end

  def completed_lesson_keys
    @completed_lesson_keys ||= lesson_progresses.where.not(completed_at: nil).pluck(:lesson_key)
  end

  def lesson_completed?(lesson_key)
    completed_lesson_keys.include?(lesson_key)
  end

  def progress_percent
    return 0 if course.lessons.empty?

    ((completed_lesson_keys.size.to_f / course.lessons.size) * 100).round
  end

  def best_quiz_attempt
    quiz_attempts.order(score: :desc, created_at: :desc).first
  end

  def latest_submission
    course_submissions.order(created_at: :desc).first
  end

  def certificate_ready?
    best_quiz_attempt&.passed? && latest_submission&.approved?
  end

  def final_score
    quiz = best_quiz_attempt&.score || 0
    submission = latest_submission&.ai_score || 0
    ((quiz * 0.55) + (submission * 0.45)).round
  end

  def issue_certificate_if_ready!
    return certificate if certificate.present?
    return unless certificate_ready?
    return unless final_score >= CERTIFICATE_THRESHOLD

    update!(completed_at: Time.current) if completed_at.blank?
    create_certificate!(final_score: final_score, issued_at: Time.current)
  end
end
