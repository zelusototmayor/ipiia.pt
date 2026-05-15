require "test_helper"

class CourseEnrollmentTest < ActiveSupport::TestCase
  test "issues certificate when quiz and workflow pass" do
    learner = Learner.create!(name: "Ana Costa", email: "ana@example.com")
    enrollment = learner.course_enrollments.create!(course_slug: CourseCatalog.fundamentos.slug, purchased_at: Time.current)

    enrollment.quiz_attempts.create!(
      answers_json: "{}",
      score: 80,
      correct_count: 12,
      question_count: 15,
      passed: true
    )
    enrollment.course_submissions.create!(
      workflow_text: "Tarefa recorrente: preparar follow-ups. Frequência: semanal. Input: notas. Passos: resumir e escrever. Output: email. Validação: rever dados. Critério de sucesso: poupar tempo.",
      ai_score: 75,
      status: "approved",
      ai_feedback_json: "{}",
      ai_provider: "mock",
      evaluated_at: Time.current
    )

    certificate = enrollment.issue_certificate_if_ready!

    assert certificate.present?
    assert_equal 78, certificate.final_score
    assert_match(/^IPIIA-FIA-/, certificate.code)
  end

  test "does not issue certificate below threshold" do
    learner = Learner.create!(name: "Bruno Reis", email: "bruno@example.com")
    enrollment = learner.course_enrollments.create!(course_slug: CourseCatalog.fundamentos.slug, purchased_at: Time.current)

    enrollment.quiz_attempts.create!(answers_json: "{}", score: 60, correct_count: 9, question_count: 15, passed: false)
    enrollment.course_submissions.create!(
      workflow_text: "Tarefa recorrente: notas semanais. Frequência: semanal. Input: notas. Passos: resumir. Output: resumo. Validação: rever. Critério de sucesso: clareza.",
      ai_score: 90,
      status: "approved",
      ai_feedback_json: "{}",
      ai_provider: "mock",
      evaluated_at: Time.current
    )

    assert_nil enrollment.issue_certificate_if_ready!
  end
end
