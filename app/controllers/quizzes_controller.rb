class QuizzesController < ApplicationController
  before_action :require_learner!
  before_action :set_enrollment

  def show
    @course = @enrollment.course
    @page_title = "Quiz final — #{@course.title}"
    @quiz = @course.quiz
    @attempt = @enrollment.best_quiz_attempt
  end

  def create
    course = @enrollment.course
    answers = params.fetch(:answers, {}).to_unsafe_h
    correct_count = course.quiz.count do |question|
      answers[question[:id]].to_i == question[:answer]
    end
    score = ((correct_count.to_f / course.quiz.size) * 100).round
    attempt = @enrollment.quiz_attempts.create!(
      answers_json: answers.to_json,
      correct_count: correct_count,
      question_count: course.quiz.size,
      score: score,
      passed: score >= CourseEnrollment::CERTIFICATE_THRESHOLD
    )

    @enrollment.issue_certificate_if_ready!
    redirect_to course_quiz_path, notice: quiz_notice(attempt)
  end

  private

  def set_enrollment
    @enrollment = current_learner.course_enrollments.active.find_by!(course_slug: CourseCatalog.fundamentos.slug)
  end

  def quiz_notice(attempt)
    return "Quiz concluído com #{attempt.score}%. Já pode submeter o workflow final." if attempt.passed?

    "Quiz concluído com #{attempt.score}%. Precisa de pelo menos #{CourseEnrollment::CERTIFICATE_THRESHOLD}% para certificado. Pode tentar novamente."
  end
end
