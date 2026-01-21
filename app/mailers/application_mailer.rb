class ApplicationMailer < ActionMailer::Base
  default from: ENV["BREVO_SENDER_EMAIL"] || "noreply@example.com"
  layout "mailer"
end
