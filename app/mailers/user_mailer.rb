class UserMailer < ApplicationMailer
  default from: 'noreply@taskpoint.com'

  def welcome_email(user)
    @user = user
    @login_url = root_url
    
    mail(
      to: @user.email,
      subject: 'Welcome to TaskPoint! 🎉'
    )
  end
end
