require 'rails_helper'

# Feature spec for testing the navigation bar
#
# The tests cover:
# - Displaying the right links for a logged-in user
# - Making sure logged out users don't see nav bar content
# - Making sure only the QA managers can see the Add New User link
#
RSpec.feature "Navigation Bar", type: :feature do

  let(:auditor) { create(:user, :auditor) }
  let(:qa_manager) { create(:user, :qa_manager) }


  scenario "Navbar shows correct links for a logged in user" do
    #Make the user and sign them in
    login_as(auditor, scope: :user)
    visit root_path

    #The other links in the unopened navbar
    expect(page).to have_link("#{auditor.first_name} #{auditor.last_name}", href: profile_path)
    expect(page).to have_link(href: notifications_path)
    expect(page).to have_link(href: auditee_dashboard_path)

    # Testing the drop down menu but not the whole thing
    find('.dropdown-btn', text: "Letters & Reports").click
    expect(page).to have_link("Audit Request Letter")
  end

  scenario "Navbar shows no links for logged out users" do
    #The lohgged out nav bar shouldnt have the same things as the login one
    expect(page).not_to have_link("#{auditor.first_name} #{auditor.last_name}", href: profile_path)
    expect(page).not_to have_link(href: notifications_path)
    expect(page).not_to have_link(href: auditee_dashboard_path)
    expect(page).not_to have_selector('.dropdown-btn')

  end

  scenario "Navbar shows no add user link for non QA admin" do
    #Make the user and sign them in
    login_as(auditor, scope: :user)
    visit root_path

    #The other links in the unopened navbar
    expect(page).to have_link("#{auditor.first_name} #{auditor.last_name}", href: profile_path)
    expect(page).to have_link(href: notifications_path)
    expect(page).to have_link(href: auditee_dashboard_path)

    # Testing the drop down menu but not the whole thing
    expect(page).to_not have_link("Add New User")
  end

  #Only the QA should be able to add a new user
  scenario "Navbar shows add user link for QA admin" do

    #Sign the user in
    login_as(qa_manager, scope: :user)
    visit root_path

    #The other links in the unopened navbar
    expect(page).to have_link("#{qa_manager.first_name} #{qa_manager.last_name}", href: profile_path)
    expect(page).to have_link(href: notifications_path)
    expect(page).to have_link(href: qa_manager_dashboard_path)

    # Test the add user link is in the navbar
    expect(page).to have_link("Add New User")
  end



end
