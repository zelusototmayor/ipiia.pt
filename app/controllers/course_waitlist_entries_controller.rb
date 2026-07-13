class CourseWaitlistEntriesController < ApplicationController
  protect_from_forgery with: :exception

  def create
    @entry = CourseWaitlistEntry.new(entry_params.merge(course_slug: CourseWaitlistEntry::PROFICIENCIA_SLUG))

    if @entry.save
      CourseWaitlistMailer.host_notification(@entry).deliver_later
      render json: {
        ok: true,
        message: "Está na lista de espera. Avisamos por email assim que o curso avançado abrir."
      }, status: :created
    elsif @entry.errors.of_kind?(:email, :taken)
      render json: { ok: true, message: "Esse email já está na lista de espera. Avisamos assim que o curso abrir." }, status: :ok
    else
      render json: { ok: false, errors: @entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def entry_params
    params.require(:course_waitlist_entry).permit(:name, :email)
  end
end
