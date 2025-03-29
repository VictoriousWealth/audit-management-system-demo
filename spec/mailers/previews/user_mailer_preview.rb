class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    user = User.first || User.new(email: "test@example.com")
    UserMailer.welcome_email(user)
  end
end
