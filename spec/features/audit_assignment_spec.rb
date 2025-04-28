require 'rails_helper'

RSpec.feature "Getting assigned an audit", type: :feature do

  let(:user2) { create(:user2) } # QA
  let(:user4) { create(:user4) } #Auditor
  let(:company) { create(:company)}
  let(:audit) { create(:audit, user: user2, company_id: company.id) }

  #Making a dummy audit assignment
  before(:each) do
    create(:audit_assignment, user: user4, assigned_by: user2.id, audit: audit, role: :lead_auditor, status: :assigned, time_accepted: nil)

  end

  #Users can see their assignments
  scenario "It should appear for the auditor" do
    login_as(user4)
    visit notifications_path

    expect(page).to have_content("Notifications")
    expect(page).to have_content("Assignments")
    expect(page).to have_content("You have a pending assignment for Audit ##{audit.id}")
    expect(page).to have_content("#{user2.first_name} #{user2.last_name}")
  end

  scenario "Auditor does not see assignments if none exist" do
    login_as(user2)
    visit notifications_path

    expect(page).to have_content("Notifications")
    expect(page).to have_content("Assignments")
    expect(page).to_not have_content("You have a pending assignment")
  end

  scenario "QA Manager sees acknowledged assignment" do
    #Acknowledge on the auditor's side
    login_as(user4)
    visit notifications_path
    find(".ack-button").click

    #Check on the qa manager's side
    login_as(user2)
    visit notifications_path

    expect(page).to have_content("Notifications")
    expect(page).to have_content("Acknowledgments")
    expect(page).to have_content("Audit ##{audit.id} has been acknowledged.")
    expect(page).to have_content("#{user4.first_name} #{user4.last_name}")
  end


  scenario "QA Manager does not see acknowledgments if none exist" do
    login_as(user2)
    visit notifications_path

    expect(page).to have_content("Notifications")
    expect(page).to have_content("Acknowledgments")
    expect(page).to_not have_content("has been acknowledged")
  end

  #Should only be visible to QAs
  scenario "Auditor does not see acknowledgments section" do
    login_as(user4)
    visit notifications_path

    expect(page).to_not have_content("Acknowledgments")
  end

  #Write tests for updating audits now - --------------- ------- -----------------------------


end
