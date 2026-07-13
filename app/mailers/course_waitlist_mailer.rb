class CourseWaitlistMailer < ApplicationMailer
  def host_notification(entry)
    @entry = entry

    mail(
      to: ENV.fetch("CONTACT_EMAIL", "zelu@zelusottomayor.com"),
      subject: "Lista de espera do curso avançado: #{entry.email}",
      reply_to: entry.email
    )
  end
end
