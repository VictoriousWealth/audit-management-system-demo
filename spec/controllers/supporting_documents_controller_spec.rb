require 'rails_helper'

RSpec.describe SupportingDocumentsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Main Street") }
  let!(:user) { User.create!(email: "user@test.com", password: "password123", role: :auditor, company: company) }
  let!(:audit) do
    Audit.create!(
      audit_type: "internal",
      company: company,
      scheduled_start_date: Date.today,
      scheduled_end_date: Date.today + 1,
      status: :not_started,
      time_of_creation: Time.zone.now
    )
  end

  before { sign_in user }

  describe "GET #new" do
    it "renders the new document form" do
      get :new, params: { audit_id: audit.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:supporting_document)).to be_a_new(SupportingDocument)
    end
  end

  describe "POST #create" do
    context "with valid parameters and file upload" do
      let(:file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"), "application/pdf") }

      it "creates the document and redirects" do
        post :create, params: {
          supporting_document: {
            name: "Policy File",
            file: file,
            content: "Document Content",
            audit_id: audit.id
          }
        }

        expect(SupportingDocument.count).to eq(1)
        expect(SupportingDocument.first.file.attached?).to be true
        expect(response).to redirect_to(view_audit_path(audit.id))
        expect(flash[:notice]).to eq("Document uploaded successfully")
      end
    end

    context "with missing required fields" do
      it "does not create document and re-renders the form" do
        post :create, params: {
          supporting_document: {
            name: "",
            audit_id: audit.id
          }
        }

        expect(SupportingDocument.count).to eq(0)
        expect(response).to render_template(:new)
        expect(flash[:notice]).to eq("Document upload failed")
      end
    end
  end

  describe "GET #show" do
    let!(:document) do
      doc = SupportingDocument.new(
        name: "Existing File",
        content: "Existing content",
        audit: audit,
        user: user
      )
      doc.file.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/sample.pdf")),
        filename: "sample.pdf",
        content_type: "application/pdf"
      )
      doc.save!
      doc
    end
  

    it "shows the supporting document" do
      get :show, params: { id: document.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:supporting_document)).to eq(document)
    end
  end
end
