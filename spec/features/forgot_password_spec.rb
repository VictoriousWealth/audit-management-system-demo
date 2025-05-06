# Ive used scenario instead of describe and specify (as seen in the training)

require 'rails_helper'

RSpec.feature "Forgot Password", type: :feature do
  let(:user) { create(:user) }

  scenario "User submits valid email for password reset" do

    #Make a user (other one not working for some reason)
    user = create(:user, email: "Auditee@User.com", password: "password")
    visit new_user_password_path
    expect(page).to have_content("Forgot Password?")

    # Fill in the data
    fill_in "Email", with: "Auditee@User.com"
    click_button "Send"

    # Expect the correct message
    expect(page).to have_content("You will receive an email with instructions on how to reset your password in a few minutes.")

    # The email should be sent
    expect(ActionMailer::Base.deliveries.count).to eq(1)
    email = ActionMailer::Base.deliveries.last

    # Verify the email
    expect(email.to).to include("auditee@user.com")
    expect(email.subject).to eq("Reset password instructions")
    expect(email.body.encoded).to include("Someone has requested a link to change your password")

  end

  scenario "User submits invalid email for password reset" do

    visit new_user_password_path

    # Put in an invalid email
    fill_in "Email", with: "invalid@example.com"
    click_button "Send"

    # Expect an error message
    expect(page).to have_content("Email not found")
  end

  scenario "User submits empty email field" do
    visit new_user_password_path

    # Leave the field blank
    fill_in "Email", with: ""
    click_button "Send"

    # Expect an error message
    expect(page).to have_content("Email can't be blank")
  end


  scenario "User changes their password successfully" do

    # Generate password reset token
    token = user.send_reset_password_instructions
    visit edit_user_password_path(reset_password_token: token)
    expect(page).to have_content("Reset your password")

    # Enter new password
    fill_in "New password", with: "newpassword"
    fill_in "Confirm your new password", with: "newpassword"
    click_button "Change my password"

    # Expect success message
    expect(page).to have_content("Your password has been changed successfully. You are now signed in.")

    # Check it works
    click_link "#{user.first_name} #{user.last_name}"
    click_link "Logout"
    visit new_user_session_path
    fill_in "Email", with: "Auditee@User.com"
    fill_in "Password", with: "newpassword"
    click_button "Login"
    expect(page).to have_content("Signed in successfully.")
  end

  scenario "User enters not matching password and confirmation" do

    # Generate password reset token
    token = user.send_reset_password_instructions
    visit edit_user_password_path(reset_password_token: token)
    expect(page).to have_content("Reset your password")

    # Fill in non matching passwords
    fill_in "New password", with: "newpassword"
    fill_in "Confirm your new password", with: "wrongpassword"
    click_button "Change my password"

    # Expect an error message
    expect(page).to have_content("Password confirmation doesn't match Password")
  end
end
