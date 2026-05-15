class AiAssessment < ApplicationRecord
  validates :name, :email, :answers_json, :dimension_scores_json, :signals_json,
    :priorities_json, :strengths_json, :overall_score, :profile_key,
    :profile_title, :profile_summary, :recommended_path, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def answers
    parse_json(answers_json)
  end

  def dimension_scores
    parse_json(dimension_scores_json)
  end

  def signals
    parse_json(signals_json)
  end

  def priorities
    parse_json(priorities_json)
  end

  def strengths
    parse_json(strengths_json)
  end

  private

  def parse_json(value)
    JSON.parse(value.presence || "{}")
  end
end
