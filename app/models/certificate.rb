class Certificate < ApplicationRecord
  belongs_to :course_enrollment

  before_validation :assign_code, on: :create

  validates :code, presence: true, uniqueness: true
  validates :final_score, :issued_at, presence: true

  private

  def assign_code
    self.code ||= "IPIIA-FIA-#{SecureRandom.alphanumeric(10).upcase}"
  end
end
