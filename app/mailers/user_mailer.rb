class UserMailer < ApplicationMailer
  # Use the authenticated Gmail as sender to avoid spoofing issues
  default from: ENV.fetch("GMAIL_EMAIL", "noreply@taskpoint.com")

  def welcome_email(user)
    @user = user
    @login_url = root_url
    
    mail(
      to: @user.email,
      subject: 'Welcome to TaskPoint! 🎉'
    )
  end

  def reset_password_email(user)
    @user = user
    @token = user.reset_password_token
    @reset_url = edit_password_url(token: @token)
    mail(to: @user.email, subject: "Redefina sua senha")
  end
end
