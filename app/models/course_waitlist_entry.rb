class CourseWaitlistEntry < ApplicationRecord
  PROFICIENCIA_SLUG = "proficiencia-implementacao-ia".freeze

  validates :email, presence: { message: "é obrigatório" }, format: { with: URI::MailTo::EMAIL_REGEXP, message: "não parece válido" }
  validates :course_slug, presence: true
  validates :email, uniqueness: { scope: :course_slug, case_sensitive: false, message: "já está na lista de espera" }

  before_validation { self.email = email.to_s.strip.downcase }
end
