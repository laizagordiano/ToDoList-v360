class UserMailer < ApplicationMailer
  default from: ENV["BREVO_SENDER_EMAIL"] || "noreply@example.com"

  def welcome_email(user)
    @user = user
    @login_url = root_url

    mail(
      to: @user.email,
      subject: "Bem-vindo ao TaskPoint! 🎉"
    )
  end

  def reset_password_email(user)
    @user = user
    @token = user.reset_password_token
    @reset_url = edit_password_url(token: @token)

    mail(
      to: @user.email,
      subject: "Redefina sua senha"
    )
  end
end
