class CoursesController < ApplicationController
  before_action :require_learner!
  before_action :set_enrollment

  def show
    @course = @enrollment.course
    @page_title = "#{@course.title} — Área do aluno"
    @next_lesson = next_lesson
  end

  def lesson
    @course = @enrollment.course
    @lesson = @course.lesson(params[:lesson_key])
    raise ActionController::RoutingError, "Not Found" if @lesson.blank?

    @page_title = "#{@lesson[:title]} — #{@course.title}"
    @progress = @enrollment.lesson_progresses.find_or_initialize_by(lesson_key: @lesson[:key])
  end

  def complete_lesson
    course = @enrollment.course
    lesson = course.lesson(params[:lesson_key])
    raise ActionController::RoutingError, "Not Found" if lesson.blank?

    progress = @enrollment.lesson_progresses.find_or_initialize_by(lesson_key: lesson[:key])
    progress.exercise_response = params[:exercise_response]
    progress.completed_at ||= Time.current
    progress.save!
    @enrollment.update!(last_lesson_key: course.next_lesson_key(lesson[:key]) || lesson[:key])

    redirect_to next_course_destination(course, lesson), notice: "Lesson concluída."
  end

  private

  def set_enrollment
    @enrollment = current_learner.course_enrollments.active.find_by!(course_slug: CourseCatalog.fundamentos.slug)
  end

  def next_lesson
    course = @enrollment.course
    key = @enrollment.last_lesson_key.presence || course.lessons.find { |lesson| !@enrollment.lesson_completed?(lesson[:key]) }&.fetch(:key)
    key.present? ? course.lesson(key) : course.first_lesson
  end

  def next_course_destination(course, lesson)
    next_key = course.next_lesson_key(lesson[:key])
    return course_lesson_path(next_key) if next_key.present?

    course_quiz_path
  end
end
