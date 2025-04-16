# spec/features/supporting_documents_spec.rb
require 'rails_helper'

RSpec.feature "SupportingDocuments", type: :feature do


  let!(:company) { create(:company) }
  let!(:audit) { create(:audit) }
  let(:user) { create(:user) }

  #Im assuming the user is on the view documents page since the feature is on cant be completed right now

#Add document path

  scenario "User is taken to add document page" do
    login_as(user, scope: :user)
    visit supporting_documents_path
    #Check the link to add new documents works
    click_link "Add Document"
    expect(page).to have_link(href: new_supporting_document_path)
  end

  scenario "shows the upload supporting documents header" do
    visit new_supporting_document_path

    expect(page).to have_content("Upload Supporting Documents for Audit")
    expect(page).to have_selector("table.general-information-table")
    expect(page).to have_content("Auditee Id")
    expect(page).to have_content("Status")
  end

  scenario "validates required fields before submission", js: true do
    visit new_supporting_document_path

    #Adding without entering data triggers an alert
    page.accept_alert "Please fill in the required fields." do
      click_button "Add"
    end

    # Check youre still on the same page
    expect(page).to have_selector("form#upload-the-document")
  end


  scenario "User uploads a new supporting document", js: true do
    visit new_supporting_document_path

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
    expect(SupportingDocument.last.name).to eq("Test Document")
  end

#View document path

  scenario "User can view uploaded documents" do
    #Upload a new document
    visit new_supporting_document_path

    attach_file "document-upload", Rails.root.join("spec/fixtures/files/sample.pdf")
    fill_in "document-title", with: "Test Document 2"
    fill_in "additional-notes", with: "Some notes"
    click_button "Add"

    #Get the document id and view it
    document = SupportingDocument.last
    expect(page).to have_content("Supporting Documents")
    expect(SupportingDocument.last.name).to eq("Test Document 2")
    expect(page).to have_content("View", )
    expect(page).to have_link(href: supporting_document_path(document.id))
    click_link "View"

    #Check the document's contents are being shown
    expect(page).to have_content("Uploaded Document")
    expect(page).to have_content("Test Document 2")
    expect(page).to have_content("Some notes")
    expect(page).to have_content("Download File")
    expect(page).to have_content("Back to Documents")
  end

end
