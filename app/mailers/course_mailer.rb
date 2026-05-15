class CourseMailer < ApplicationMailer
  def access_link(enrollment)
    @enrollment = enrollment
    @learner = enrollment.learner
    @course = enrollment.course
    @login_url = magic_course_session_url(
      token: @learner.signed_id(purpose: :course_login, expires_in: 14.days),
      host: ENV.fetch("APP_HOST", "ipiia.pt"),
      protocol: "https",
      port: nil
    )

    mail(
      to: @learner.email,
      subject: "Acesso ao curso #{@course.title} - IPIIA"
    )
  end

  def certificate_issued(certificate)
    @certificate = certificate
    @enrollment = certificate.course_enrollment
    @learner = @enrollment.learner
    @course = @enrollment.course
    @certificate_url = certificate_url(
      @certificate.code,
      host: ENV.fetch("APP_HOST", "ipiia.pt"),
      protocol: "https",
      port: nil
    )

    attachments["#{@certificate.code}.pdf"] = CertificatePdf.new(@certificate).render

    mail(
      to: @learner.email,
      subject: "O seu certificado IPIIA está pronto"
    )
  end
end
