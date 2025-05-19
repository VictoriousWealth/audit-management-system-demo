require 'rails_helper'

RSpec.feature "Getting assigned an audit", type: :feature do
  let!(:company) { create(:company) }
  let!(:qa_manager) { create(:user2, company:) }
  let!(:auditor) { create(:user4, company:) }
  let!(:audit) { create(:audit, user: qa_manager, company:) }

<<<<<<< HEAD
  let(:auditor) { create(:user, :auditor) }
  let(:qa_manager) { create(:user, :qa_manager) }
  let(:company) { create(:company)}
  let(:audit) { create(:audit, user: qa_manager, company_id: company.id) }

  #Making a dummy audit assignment
  before(:each) do
    create(:audit_assignment, user: auditor, assigned_by: qa_manager.id, audit: audit, role: :lead_auditor, status: :assigned, time_accepted: nil)
  end

  #Users can see their assignments
  scenario "It should appear for the auditor" do
    login_as(auditor)
    visit notifications_path

    expect(page).to have_content("Notifications")
    expect(page).to have_content("Assignments")
    expect(page).to have_content("You have a pending assignment for Audit ##{audit.id}")
    expect(page).to have_content("#{qa_manager.first_name} #{qa_manager.last_name}")
  end

  scenario "Auditor does not see assignments if none exist" do
    login_as(qa_manager)
    visit notifications_path

    expect(page).to have_content("Notifications")
    expect(page).to have_content("Assignments")
    expect(page).to_not have_content("You have a pending assignment")
  end

  scenario "QA Manager sees acknowledged assignment" do
    #Acknowledge on the auditor's side
    login_as(auditor)
    visit notifications_path
    find(".ack-button").click

    #Check on the qa manager's side
    login_as(qa_manager)
    visit notifications_path

    expect(page).to have_content("Notifications")
    expect(page).to have_content("Acknowledgments")
    expect(page).to have_content("Audit ##{audit.id} has been acknowledged.")
    expect(page).to have_content("#{auditor.first_name} #{auditor.last_name}")
  end


  scenario "QA Manager does not see acknowledgments if none exist" do
    login_as(qa_manager)
    visit notifications_path

    expect(page).to have_content("Notifications")
    expect(page).to have_content("Acknowledgments")
    expect(page).to_not have_content("has been acknowledged")
  end

  #Should only be visible to QAs
  scenario "Auditor does not see acknowledgments section" do
    login_as(auditor)
    visit notifications_path

    expect(page).to_not have_content("Acknowledgments")
  end

  #Write tests for updating audits now - --------------- ------- -----------------------------


=======
  context "when an audit assignment exists" do
    let!(:assignment) do
      create(:audit_assignment,
        user: auditor,
        assigned_by: qa_manager.id,
        audit: audit,
        role: :lead_auditor,
        status: :assigned,
        time_accepted: nil
      )
    end

    scenario "Auditor sees their pending assignment" do
      login_as(auditor)
      visit notifications_path

      expect(page).to have_content("Notifications")
      expect(page).to have_content("Assignments")
      expect(page).to have_content("You have a pending assignment for Audit ##{audit.id}")
      expect(page).to have_content("#{qa_manager.first_name} #{qa_manager.last_name}")
    end

    scenario "QA Manager sees the acknowledged assignment after auditor accepts" do
      login_as(auditor)
      visit notifications_path
      save_and_open_page
      find(".ack-button", visible: :all).click

      # Wait for the row to disappear (the row should go away after acknowledgment)
      expect(page).to have_no_selector(".ack-button", wait: 5)
      
      logout(auditor)


      login_as(qa_manager)
      visit notifications_path

      expect(page).to have_content("Acknowledgments")
      expect(page).to have_content("Audit ##{audit.id} has been acknowledged.")
      expect(page).to have_content("#{auditor.first_name} #{auditor.last_name}")
    end
  end

  context "when no audit assignments exist" do
    scenario "Auditor does not see any pending assignments" do
      login_as(auditor)
      visit notifications_path

      expect(page).to have_content("Notifications")
      expect(page).to have_content("Assignments")
      expect(page).to_not have_content("You have a pending assignment")
    end

    scenario "QA Manager sees no acknowledgments" do
      login_as(qa_manager)
      visit notifications_path

      expect(page).to have_content("Notifications")
      expect(page).to have_content("Acknowledgments")
      expect(page).to_not have_content("has been acknowledged")
    end

    scenario "Auditor does not see acknowledgments section" do
      login_as(auditor)
      visit notifications_path

      expect(page).to_not have_content("Acknowledgments")
    end
  end
>>>>>>> 3d0f531c4e06c68519911e4d1e4bed00928836f6
end
