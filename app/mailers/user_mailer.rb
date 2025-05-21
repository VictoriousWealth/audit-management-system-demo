# Handles emails for welcome messages and account set up instructions
class UserMailer < ApplicationMailer
  # Sets the default from address for all mail sent by this mailer
  default from: 'mailhost.shef.ac.uk'

  # Sends a welcome email to a new user, including a reset password link.
  #
  # @param user [User] the user to send the welcome email to
  # @return [Mail::Message] the email object
  def welcome_email(user)
    @user = user
    @reset_password_url = edit_user_password_url(@user, reset_password_token: @user.send_reset_password_instructions)
    #Recipient and subject
    mail(to: @user.email, subject: 'GTIMC Account Creation')
  end
end