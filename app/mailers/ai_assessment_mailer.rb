class AiAssessmentMailer < ApplicationMailer
  def results(assessment)
    @assessment = assessment

    mail(
      to: assessment.email,
      subject: "O seu diagnóstico de prontidão IA - IPIIA"
    )
  end

  def host_notification(assessment)
    @assessment = assessment

    mail(
      to: ENV.fetch("CONTACT_EMAIL", "zelu@zelusottomayor.com"),
      subject: "Novo teste IA: #{assessment.name} - #{assessment.profile_title}",
      reply_to: assessment.email
    )
  end
end
