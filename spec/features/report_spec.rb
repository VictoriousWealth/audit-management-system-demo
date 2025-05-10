require 'rails_helper'
# Feature spec for testing the creation of a new audit report
# 
# This spec covers the following scenarios:
# - User can see the audit information
# - User can see create new audit findings
# - User can see the audit findings
# - User can see the audit findings in the report

RSpec.feature "Create Report", type: :feature do
  let!(:auditor) {FactoryBot.create(:user4)}
  let!(:lead_auditor) {FactoryBot.create(:user5)}
  let!(:qa_manager) { FactoryBot.create(:user2) }

  let!(:company) { FactoryBot.create(:company, id: 1) }
  let!(:auditee) { FactoryBot.create(:user, company: company) }

  let!(:audit) { FactoryBot.create(:audit, company: company, user: qa_manager) }
  let!(:audit_detail) { FactoryBot.create(:audit_detail, audit: audit) }
  let!(:audit_assignment1){FactoryBot.create(:audit_assignment, user: auditor, audit: audit, role: 1, assigner: qa_manager)}
  let!(:audit_assignment2) {FactoryBot.create(:audit_assignment, user: lead_auditor, audit: audit, role: 0,assigner: qa_manager)}
  let!(:audit_assignment3) {FactoryBot.create(:audit_assignment, user: auditee, audit: audit, role: 3, assigner: qa_manager)}

  let!(:audit_standard) { FactoryBot.create(:audit_standard, audit_detail: audit_detail) }

  before do
    login_as qa_manager
  end

  scenario "User can see the audit information without subject matter experts" do
    visit new_audit_report_path(audit)
    puts "Audit page visited - running test 1"

    expect(page).to have_content("Audit Details")
    expect(page).to have_content("Audit Scope")
    expect(page).to have_content("The scope of test audit")

    expect(page).to have_content("Auditors Details")
    expect(page).to have_content("Lead Auditor")
    expect(page).to have_content("Auditor Two")

    expect(page).to have_content("Assigned Auditor(s)")
    expect(page).to have_content("Auditor User")

    expect(page).to have_content("Auditee Details")
    expect(page).to have_content("Company 1")
    expect(page).to have_content("Auditee User")

    expect(page).to have_content("Detailed Findings")
  end

  let!(:sme) { FactoryBot.create(:user6) }
  let!(:audit_assignment4) {FactoryBot.create(:audit_assignment, user: sme, audit: audit, role: 2, assigner: qa_manager)}

  scenario "User can see the audit information with subject matter experts" do

    visit new_audit_report_path(audit)
    puts "Audit page visited - running test 2"

    expect(page).to have_content("Audit Details")
    expect(page).to have_content("Audit Scope")
    expect(page).to have_content("The scope of test audit")

    expect(page).to have_content("Auditors Details")
    expect(page).to have_content("Lead Auditor")
    expect(page).to have_content("Auditor Two")

    expect(page).to have_content("Assigned Auditor(s)")
    expect(page).to have_content("Auditor User")

    expect(page).to have_content("Auditee Details")
    expect(page).to have_content("Company 1")
    expect(page).to have_content("Auditee User")

    expect(page).to have_content("Subject Matter Expert(s)")
    expect(page).to have_content("SME User")

    expect(page).to have_content("Detailed Findings")
  end

  scenario "User can create new audit findings" do
    visit new_audit_report_path(audit)
    puts "Audit page visited - running test 3"

    click_link "Add New Finding"

    fill_in "Description", with: "New Finding"
    select "Critical", from: "Category"
    select "High", from: "Risk Level"
    fill_in "Due Date", with: "2025-05-10"

    click_button "Save"

    expect(page).to have_content("Finding added (not saved yet)")
    expect(page).to have_content("New Finding")
    expect(page).to have_content("Critical")
    expect(page).to have_content("High")
    expect(page).to have_content("10/05/2025")
  end
end
