class BookingMailer < ApplicationMailer
  def confirmation(booking)
    @booking = booking

    mail(
      to: booking.guest_email,
      subject: "Pedido de intro call recebido - IPIIA"
    )
  end

  def confirmed_with_meet_link(booking)
    @booking = booking

    mail(
      to: booking.guest_email,
      subject: "Intro call confirmada - IPIIA"
    )
  end

  def cancellation(booking)
    @booking = booking

    mail(
      to: booking.guest_email,
      subject: "Intro call cancelada - IPIIA"
    )
  end

  def host_notification(booking)
    @booking = booking

    mail(
      to: ENV.fetch("CONTACT_EMAIL", "zelu@zelusottomayor.com"),
      subject: "Nova intro call IPIIA: #{booking.guest_name}",
      reply_to: booking.guest_email
    )
  end
end
