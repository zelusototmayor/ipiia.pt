class QuizAttempt < ApplicationRecord
  belongs_to :course_enrollment

  validates :answers_json, :score, :correct_count, :question_count, presence: true

  def answers
    JSON.parse(answers_json.presence || "{}")
  end
end
