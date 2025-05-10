require "rails_helper"

describe "Creating a new audit request letter" do
  let!(:auditor) {FactoryBot.create(:user4)}
  let!(:lead_auditor) {FactoryBot.create(:user5)}


  let!(:company) { FactoryBot.create(:company, id: 1) }
  puts "Companies created: #{Company.count}"


  let!(:qa_manager) { FactoryBot.create(:user2) }
  puts "Users created: #{User.count}"

  let!(:audit) { FactoryBot.create(:audit, company: company, user: qa_manager) }
  puts "Audits created: #{Audit.count}"
  

  let!(:audit_detail) { FactoryBot.create(:audit_detail, audit: audit) }
  puts "Audit details created: #{AuditDetail.count}"

  let!(:audit_assignment){FactoryBot.create(:audit_assignment, user: auditor, audit: audit, role: 1, assigner: qa_manager)}
  let!(:audit_assignment) {FactoryBot.create(:audit_assignment, user: lead_auditor, audit: audit, role: 0,assigner: qa_manager)}

  let!(:audit_standard) { FactoryBot.create(:audit_standard, audit_detail: audit_detail) }
  puts "Audit standards created: #{AuditStandard.count}"
  before do
    login_as qa_manager
  end
  specify "User can see the prefilled data" do
    visit new_audit_audit_request_letters_path(audit)
    puts "Audit request letter page visited - running test 1"

    expect(page).to have_content("Audit Request Letter")
    expect(page).to have_field("audit_scope", with: "The scope of test audit")
    expect(page).to have_field("audit_criteria", with:"Standard 1")
    expect(page).to have_field("audit_purpose", with: "Purpose of test audit")
    expect(page).to have_field("audit_objectives", with: "Objectives of test audit") 
    expect(page).to have_field("audit_boundaries", with: "Boundaries of test audit") 
  end
  specify "User can enter new data" do
    visit new_audit_audit_request_letters_path(audit)
    puts "Audit request letter page visited - running test 2"

    fill_in "audit_scope", with: "New scope"
    fill_in "audit_criteria", with: "New criteria"
    fill_in "audit_purpose", with: "New purpose"
    fill_in "audit_objectives", with: "New objectives"
    fill_in "audit_boundaries", with: "New boundaries"

    click_button "Preview"
    puts "Audit request letter created"

    expect(page).to have_content("Audit Request Letter created successfully.")
  end
  specify "User can see the new data" do
    visit new_audit_audit_request_letters_path(audit)
    puts "Audit request letter page visited - running test 3"

    fill_in "audit_scope", with: "New scope"
    fill_in "audit_criteria", with: "New criteria"
    fill_in "audit_purpose", with: "New purpose"
    fill_in "audit_objectives", with: "New objectives"
    fill_in "audit_boundaries", with: "New boundaries"

    click_button "Preview"
    puts "Audit request letter created"

    expect(page).to have_content("New scope")
    expect(page).to have_content("New criteria")
    expect(page).to have_content("New purpose")
    expect(page).to have_content("New objectives")
    expect(page).to have_content("New boundaries")
  end
  specify "User can see the new data in the audit request letter" do
    visit new_audit_audit_request_letters_path(audit)
    puts "Audit request letter page visited - running test 4"

    fill_in "audit_scope", with: "New scope"
    fill_in "audit_criteria", with: "New criteria"
    fill_in "audit_purpose", with: "New purpose"
    fill_in "audit_objectives", with: "New objectives"
    fill_in "audit_boundaries", with: "New boundaries"

    click_button "Preview"
    puts "Audit request letter created"
    expect(page).to have_content("Audit Request Letter created successfully.")


    visit audit_audit_request_letters_path(audit)
    expect(page).to have_content("Audit Request Letter")
    expect(page).to have_content("New scope")
    expect(page).to have_content("New criteria")
    expect(page).to have_content("New purpose")
    expect(page).to have_content("New objectives")
    expect(page).to have_content("New boundaries")
  end
  specify "User can verify audit request letter" do
    visit new_audit_audit_request_letters_path(audit)
    puts "Audit request letter page visited - running test 5"

    fill_in "audit_scope", with: "New scope"
    fill_in "audit_criteria", with: "New criteria"
    fill_in "audit_purpose", with: "New purpose"
    fill_in "audit_objectives", with: "New objectives"
    fill_in "audit_boundaries", with: "New boundaries"

    click_button "Preview"
    puts "Audit request letter created"
    expect(page).to have_content("Audit Request Letter created successfully.")
    expect(page).to have_content("Audit Request Letter")
    expect(page).to have_content("New scope")
    expect(page).to have_content("New criteria")
    expect(page).to have_content("New purpose")
    expect(page).to have_content("New objectives")
    expect(page).to have_content("New boundaries")

    click_button "Verify"
    expect(page).to have_content("Audit Request Letter verified successfully.")
  end
end