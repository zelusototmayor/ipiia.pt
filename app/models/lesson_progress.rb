class LessonProgress < ApplicationRecord
  belongs_to :course_enrollment

  validates :lesson_key, presence: true, uniqueness: { scope: :course_enrollment_id }

  def completed?
    completed_at.present?
  end
end
