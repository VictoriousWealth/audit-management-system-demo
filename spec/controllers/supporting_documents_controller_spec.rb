require 'rails_helper'
# RSpec tests for the SupportingDocumentsController
#
# It tests that:
# - The new action initialises an instance for a new supporting document
# - The create action successfully saves a new supporting document with an uploaded file upload.
#
RSpec.describe SupportingDocumentsController, type: :controller do
  let!(:audit) { Audit.create!(name: "Test Audit") }

  describe "GET #new" do
    it "assigns a new SupportingDocument" do
      get :new
      expect(assigns(:supporting_document)).to be_a_new(SupportingDocument)
    end
  end

  describe "POST #create" do
    let(:file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"), 'application/pdf') }
    it "creates a new supporting document with a file" do
      post :create, params: {
        supporting_document: {
          name: "Uploaded Doc",
          content: "Some notes",
          file: file
        }
      }
      expect(SupportingDocument.count).to eq(1)
      expect(SupportingDocument.last.name).to eq("Uploaded Doc")
      expect(response).to redirect_to(supporting_documents_path)
    end
  end
end
