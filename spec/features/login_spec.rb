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

  let(:auditee) { create(:user, :auditee) }
  let(:auditor) { create(:user, :auditor) }
  let(:qa_manager) { create(:user, :qa_manager) }
  let(:senior_manager) { create(:user, :senior_manager) }
  let(:sme) { create(:user, :sme) }

  scenario "User logs in with correct details" do
    visit new_user_session_path
    fill_in "Email", with: auditor.email
    fill_in "Password", with: auditor.password
    click_button "Login"
    expect(page).to have_content("Signed in successfully")
  end

  scenario "User enters incorrect password" do
    visit new_user_session_path
    fill_in "Email", with: auditor.email
    fill_in "Password", with: "wrongpassword"
    click_button "Login"
    expect(page).to have_content("Invalid Email or password")
  end

  scenario "User enters non existing email" do
    visit new_user_session_path
    fill_in "Email", with: "dog"
    fill_in "Password", with: auditor.password
    click_button "Login"
    expect(page).to have_content("Invalid Email or password")
  end

  scenario "User Log  out" do
    #Login
    login_as(auditor, scope: :user)
    visit root_path
    #Go to the profile page and log out
    click_link "#{auditor.first_name} #{auditor.last_name}"
    click_link "Logout"

    #Check the user is taken back to the home page
    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Signed out successfully.")
  end

  scenario "User is an auditor" do
    login_as(auditor, scope: :user)
    visit root_path
    #Path should be the correct dashboard
    expect(page).to have_current_path(dashboard_path_for(auditor))
  end

  scenario "User is an auditee" do
    login_as(auditee, scope: :user)
    visit root_path
    #Path should be the correct dashboard
    expect(page).to have_current_path(dashboard_path_for(user))
  end

  scenario "User is a QA Manager" do
    login_as(qa_manager, scope: :user)
    visit root_path
    #Path should be the correct dashboard
    expect(page).to have_current_path(dashboard_path_for(qa_manager))
  end

  scenario "User is an Senior Manager" do
    login_as(senior_manager, scope: :user)
    visit root_path
    #Path should be the correct dashboard
    expect(page).to have_current_path(dashboard_path_for(senior_manager))
  end

  scenario "User is an SME" do
    login_as(sme, scope: :user)
    visit root_path
    #Path should be the correct dashboard
    expect(page).to have_current_path(dashboard_path_for(sme))
  end

end
