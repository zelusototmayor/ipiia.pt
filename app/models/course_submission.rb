class CourseSubmission < ApplicationRecord
  belongs_to :course_enrollment

  validates :workflow_text, presence: true, length: { minimum: 120 }

  def feedback
    JSON.parse(ai_feedback_json.presence || "{}")
  end

  def approved?
    status == "approved"
  end
end
