class UserMailer < ApplicationMailer
  #default from: 'your-email@example.com'

  #For when accounts are created
  def welcome_email(user)
    @user = user
    @reset_password_url = edit_user_password_url(@user, reset_password_token: @user.send_reset_password_instructions)
    mail(to: @user.email, subject: 'GTIMC Account Creation')
  end
end
