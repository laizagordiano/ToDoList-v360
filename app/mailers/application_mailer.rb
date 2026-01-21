class ApplicationMailer < ActionMailer::Base
  default from: ENV["POSTMARK_SENDER_EMAIL"]
  layout "mailer"
end
