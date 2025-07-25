require 'rails_helper'

# Feature spec for testing user profile and edit profile functionality
#
# The tests cover:
# - Accessing the profile page and displaying user's details
# - Making sure that company details are displayed only for auditees
# - Testing the profile is updated with valid and invalid data
# - Making sure the back button works
#
RSpec.feature "User Profile", type: :feature do

  let(:user) { create(:user) }
  let(:auditee) { create(:user, :auditee) }
  let(:qa_manager) { create(:user, :qa_manager) }
  let(:auditor) { create(:user, :auditor) }

  let(:user3) { create(:user3) }


  scenario "Get to profile page" do
    #Login
    login_as(auditor, scope: :user)
    visit profile_path

    #Check it has the correct user details
    expect(page).to have_current_path(profile_path)
    expect(page).to have_content("#{auditor.first_name} #{auditor.last_name}")
    expect(page).to have_content(auditor.email)
    expect(page).to have_content(auditor.role)
  end

  scenario "Profile page should have company details if the user is an auditee" do
    #Login
    login_as(auditee, scope: :user)
    visit profile_path

    #Check it has the correct user details
    expect(page).to have_current_path(profile_path)
    expect(page).to have_content("#{auditee.first_name} #{auditee.last_name}")
    expect(page).to have_content(auditee.email)
    expect(page).to have_content(auditee.role)
    expect(page).to have_content("Company")
    expect(page).to have_content("Address")

  end

  scenario "Profile page shouldnt have company if the user isnt an auditee" do
    #Login
    login_as(auditor, scope: :user)
    visit profile_path

    #Check it has the correct user details
    expect(page).to have_current_path(profile_path)
    expect(page).to have_content("#{auditor.first_name} #{auditor.last_name}")
    expect(page).to have_content(auditor.email)
    expect(page).to have_content(auditor.role.humanize.capitalize)

    #Company is there it just shouldnt be visible
    expect(page).to_not have_selector("b", text: "Company")
    expect(page).to_not have_selector("b", text: "Address")

  end

  scenario "User visits the profile edit page" do
    #Login
    login_as(auditor, scope: :user)
    visit edit_user_registration_path

    #Check it has the right fields
    expect(page).to have_content("Edit Profile")
    expect(page).to have_selector("input[placeholder='Enter new email']")
    expect(page).to have_selector("input[placeholder='Enter new password']")
    expect(page).to have_selector("input[placeholder='Confirm your new password']")
    expect(page).to have_selector("input[placeholder='Enter your current password']")
    expect(page).to have_button("Update")
    expect(page).to have_link("Back", href: profile_path)
  end

  scenario "User updates profile with valid data" do

    #Login
    login_as(auditor, scope: :user)
    visit edit_user_registration_path

    #Enter the valid details
    fill_in "Enter new email", with: "newemail@example.com"
    fill_in "Enter new password", with: "newpassword"
    fill_in "Confirm your new password", with: "newpassword"
    fill_in "Enter your current password", with: "Password"
    click_button "Update"

    #Should be a success
    expect(page).to have_content("Your account has been updated successfully.")
    expect(current_path).to eq(dashboard_path_for(user))
  end

  scenario "User updates profile with invalid email" do

     #Login
     login_as(auditor, scope: :user)
     visit edit_user_registration_path

    #Enter invalid email
    fill_in "Enter new email", with: "invalid-email"
    fill_in "Enter your current password", with: "Password"
    click_button "Update"

    expect(page).to have_content("Email is invalid")
  end

  scenario "User updates with existing email" do
    #Make a user with the email
    create(:user, email: "QA@auditor.com", password: "password")

    #Login
    login_as(auditor, scope: :user)
    visit edit_user_registration_path

   #Enter invalid email
   fill_in "Enter new email", with: "QA@auditor.com"
   fill_in "Enter your current password", with: "Password"
   click_button "Update"

   expect(page).to have_content("Email has already been taken")
 end

  scenario "User updates profile with mismatched passwords" do

     #Login
     login_as(auditor, scope: :user)
     visit edit_user_registration_path

    #Dont enter the same passwords
    fill_in "Enter new password", with: "newpassword"
    fill_in "Confirm your new password", with: "differentpassword"
    fill_in "Enter your current password", with: "Password"
    click_button "Update"

    #Should raise an error
    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  scenario "User updates profile with incorrect current password" do

     #Login
     login_as(auditor, scope: :user)
     visit edit_user_registration_path

    #Enter incorrect password
    fill_in "Enter new email", with: "new@email.com"
    fill_in "Enter your current password", with: "wrongpassword"
    click_button "Update"
    #Should raise an error
    expect(page).to have_content("Current password is invalid")
  end

  scenario "User clicks the 'Back' button" do

     #Login
     login_as(auditor, scope: :user)
     visit edit_user_registration_path

    #sHOULD TAKE USER TO PROFILE PAGE
    click_link "Back"
    expect(current_path).to eq(profile_path)
  end

end
