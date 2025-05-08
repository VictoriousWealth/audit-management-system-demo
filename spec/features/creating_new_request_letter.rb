# This line includes the Rails test helper, which sets up the test environment
require "rails_helper"

RSpec.describe "Creating a new audit request letter", type: :feature do
  include Devise::Test::IntegrationHelpers

  puts "------------sdfsdiofjosjpdfsd"
  Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # All IPv4 addresses.
  IPAddr.new("::/0"),             # All IPv6 addresses.
  "localhost",                    # The localhost reserved domain.
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # Additional comma-separated hosts for development.
]
puts "------------------sdfsdiofjosjpdfsd"



  # let!(:company) { FactoryBot.create(:company, id: 1) }

  let!(:auditor) {FactoryBot.create(:user, :auditor)}
  let!(:lead_auditor) {FactoryBot.create(:user, :auditor)}
  let!(:qa_man) { FactoryBot.create(:user, :qa_manager) }

  let!(:audit) { FactoryBot.create(:audit, :with_detail_and_standards, :basic_team) }
  

  # let!(:audit_detail) { FactoryBot.create(:audit_detail, :with_standards ,audit: audit) }

  # let!(:audit_standard) { FactoryBot.create(:audit_standard, audit_detail: audit_detail) }
  # puts "Audit standards created: #{AuditStandard.count}"
  before do
    login_as qa_man
  end
  specify "User can see the prefilled data" do

    visit new_audit_audit_request_letters_path(audit)
    puts page.body
    save_and_open_page
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