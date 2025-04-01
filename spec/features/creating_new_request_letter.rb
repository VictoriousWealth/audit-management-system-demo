require "rails_helper"

describe "Creating a new audit request letter" do
  specify "User can see the prefilled data" do
    user = User.create(email: 'manager.email.address@sheffield.ac.uk', password: 'Password123', password_confirmation: 'Password123', manager: true)
    login_as user
    
    audit = FactoryBot.create(:audit)
    audit_detail = FactoryBot.create(:audit_detail, audit: audit)

    visit new_audit_audit_request_letter_path(audit)

    expect(page).to have_content("Audit Request Letter")
    expect(page).to have_field("Scope", with: "The scope of test audit")
    expect(page).to have_content("The Purpose of test audit")
    expect(page).to have_content("Audit Scope")
    expect(page).to have_content("Audit Purpose") 


