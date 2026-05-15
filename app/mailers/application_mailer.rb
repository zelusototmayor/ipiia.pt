class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_EMAIL", "IPIIA <zelu@zelusottomayor.com>")
  layout "mailer"
end
