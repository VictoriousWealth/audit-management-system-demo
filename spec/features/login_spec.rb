require 'rails_helper'

# Feature spec for testing devise's user authentication
#
# Tests cover:
# - Correctly logging
# - Incorrect login attempts
# - Logging out
# - Redirection to specific dashboards based on the user's role
#
RSpec.feature "User Authentication", type: :feature do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }
  let(:user4) { create(:user) }

  scenario "User logs in with correct details" do
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Login"

    expect(page).to have_content("Signed in successfully")
  end

  scenario "User enters incorrect password" do
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "wrongpassword"
    click_button "Login"

    expect(page).to have_content("Invalid Email or password")
  end

  scenario "User enters non existing email" do
    visit new_user_session_path
    fill_in "Email", with: "dog"
    fill_in "Password", with: user.password
    click_button "Login"

    expect(page).to have_content("Invalid Email or password")
  end

  scenario "User Log  out" do
    #Login
    login_as(user, scope: :user)
    visit root_path

    #Go to the profile page and log out
    click_link "#{user.first_name} #{user.last_name}"
    click_link "Logout"

    #Check the user is taken back to the home page
    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Signed out successfully.")
  end

  scenario "User is an auditor" do
    login_as(user4, scope: :user)
    visit root_path

    #Path should be the correct dashboard
    expect(page).to have_current_path(dashboard_path_for(user4))
  end

  scenario "User is an auditee" do
    login_as(user, scope: :user)
    visit root_path
    #Path should be the correct dashboard
    expect(page).to have_current_path(dashboard_path_for(user))

  end

  scenario "User is a QA Manager" do
    login_as(user2, scope: :user)
    visit root_path
    #Path should be the correct dashboard
    expect(page).to have_current_path(dashboard_path_for(user2))
  end

  scenario "User is an Senior Manager" do
    login_as(user3, scope: :user)
    visit root_path
    #Path should be the correct dashboard
    expect(page).to have_current_path(dashboard_path_for(user3))
  end


end
