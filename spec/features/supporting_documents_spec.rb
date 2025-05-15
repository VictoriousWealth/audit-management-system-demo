# spec/features/supporting_documents_spec.rb
require 'rails_helper'

# Feature spec for testing the supporting documents functionality
#
#These tests cover:
# - Viewing the correct supporting documents data
# - Going to the page for adding new documents
# - Checking the document upload page renders correctly and handles validation errors
# - Ensuring that a document can be uploaded successfully with previews and data saving.
#
RSpec.feature "SupportingDocuments", type: :feature do


  let!(:company) { create(:company) }
  let!(:audit) { create(:audit,company: company) }
  let(:user) { create(:user) }
  let(:user2) { create(:user, role: "auditor") }

  #Check thwe view is correct for an auditee
  scenario "The user can see the supporting documents section" do
    login_as(user, scope: :user)
    visit view_audit_path(audit.id)
    #Check everything is correct
    expect(page).to have_content("Supporting Documents")
    expect(page).to have_content("No supporting documents available")
    expect(page).to have_content("Add Document")
  end

  #Check the view is correct for a non-auditee
  scenario "The non user should not see add button in the supporting documents section" do
    login_as(user2, scope: :user)
    visit view_audit_path(audit.id)
    #Check everything is correct
    expect(page).to have_content("Supporting Documents")
    expect(page).to have_content("No supporting documents available")
    expect(page).to_not have_content("Add Document")
  end

  #Check the button takes the user to the /new page
  scenario "The user can go to the add document page" do
    login_as(user, scope: :user)
    visit view_audit_path(audit.id)
    expect(page).to have_content("Supporting Documents")
    #Check the link to add new documents works
    click_link "Add Document"
    expect(page).to have_link(href: new_supporting_document_path)
  end

  #Check the new document page loads right
  scenario "shows the upload supporting documents headers" do
    login_as(user, scope: :user)
    visit view_audit_path(audit.id)
    expect(page).to have_content("Supporting Documents")
    click_link "Add Document"
    #Check the headings
    expect(page).to have_content("Upload Supporting Document for #Audit #{audit.id}")
    expect(page).to have_content("Upload Document")
    expect(page).to have_content("Add attachment details")
    expect(page).to have_content("Document Title")
    expect(page).to have_content("Attachment")
    expect(page).to have_content("Additional Notes")
    expect(page).to have_content("Add")
  end


  #Check what happens if no data is entered and the user tries to add
  scenario "validates required fields before submission", js: true do
    login_as(user, scope: :user)
    visit view_audit_path(audit.id)
    expect(page).to have_content("Supporting Documents")
    click_link "Add Document"
    expect(page).to have_selector("form#upload-the-document")
    # Trigger the alert by submitting empty form (not filling in the details)
    page.accept_alert "Please fill in the required fields." do
      click_button "Add"
    end
  end

  #Add a new document
  scenario "User uploads a new supporting document", js: true do
    login_as(user, scope: :user)
    visit view_audit_path(audit.id)
    expect(page).to have_content("Supporting Documents")
    click_link "Add Document"

    #Upload and fill in the documents details
    attach_file "document-upload", Rails.root.join("spec/fixtures/files/sample.pdf")
    #Should be able to then preview the file
    expect(page).to have_selector(".file-preview", text: "sample.pdf")
    expect(page).to have_link("View File")
    fill_in "document-title", with: "Test Document"
    fill_in "additional-notes", with: "Some notes"
    click_button "Add"
    #Check its been uploaded
    expect(page).to have_content("Supporting Documents")
    expect(page).to have_content("Some notes")
    expect(SupportingDocument.last.name).to eq("Test Document")
  end
end
