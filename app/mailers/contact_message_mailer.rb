class ContactMessageMailer < ApplicationMailer
  def host_notification(contact_message)
    @contact_message = contact_message

    mail(
      to: ENV.fetch("CONTACT_EMAIL", "zelu@zelusottomayor.com"),
      subject: "Novo contacto pelo site: #{contact_message.name}",
      reply_to: contact_message.email
    )
  end
end
