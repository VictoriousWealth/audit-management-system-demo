require 'rails_helper'
# RSpec tests for the SupportingDocumentsController
#
# It tests that:
# - The new action initialises an instance for a new supporting document
# - The create action successfully saves a new supporting document with an uploaded file upload.
#
RSpec.describe SupportingDocumentsController, type: :controller do
  let!(:audit) { create (:audit) }
  let!(:user) { create(:user) }  # Create test user

  describe "GET #new" do
    let(:user) { create(:user) }  # Create test user

    before do
      sign_in user  # Authenticate user before each test
    end

    it "assigns a new SupportingDocument" do
      audit = create(:audit)

      get :new, params: { audit_id: audit.id }

      # Debugging outputs (optional)
     # puts "Audit ID: #{audit.id}"
      #puts "Assigned document: #{assigns(:supporting_document).inspect}"

      # Expectations
      expect(assigns(:supporting_document)).to be_a_new(SupportingDocument)
      expect(assigns(:supporting_document).audit_id).to eq(audit.id)
    end
  end

  describe "POST #create" do
    let(:user) { create(:user) }
    let(:audit) { create(:audit) } # Add audit creation
    let(:file) {
      fixture_file_upload(
        Rails.root.join("spec/fixtures/files/sample.pdf"),
        'application/pdf'
      )
    }

    before do
      sign_in user
    end

    it "creates a new supporting document with a file" do
      post :create, params: {
        audit_id: audit.id, # Add nested audit ID
        supporting_document: {
          name: "Uploaded Doc",
          content: "Some notes",
          file: file,
          audit_id: audit.id # Ensure audit association
        }
      }

      # Expectations
      expect(SupportingDocument.count).to eq(1)
      created_doc = SupportingDocument.last

      expect(created_doc.name).to eq("Uploaded Doc")
      expect(created_doc.audit_id).to eq(audit.id)
      expect(created_doc.user_id).to eq(user.id)
      expect(created_doc.file).to be_attached

      expect(response).to redirect_to(view_audit_path(audit)) # Correct redirect path
    end
  end

  describe "GET #show" do
    let(:user) { create(:user) }
    let(:audit) { create(:audit) }
    let(:document) do
      create(:supporting_document,
            user: user,
            audit: audit,
            file: fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"),
            content: "Test content"))
    end

    context "when authenticated" do
      before { sign_in user }

      it "assigns the requested document" do
        get :show, params: { id: document.id }
        expect(assigns(:supporting_document)).to eq(document)
      end

      it "renders the show template" do
        get :show, params: { id: document.id }
        expect(response).to render_template(:show)
      end

      context "when document doesn't exist" do
        it "raises not found error" do
          expect {
            get :show, params: { id: 9999 }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "when unauthenticated" do
      it "redirects to login" do
        get :show, params: { id: document.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Test for set_supporting_document callback specifically
  describe "#set_supporting_document" do
    let(:user) { create(:user) }
    let(:document) { create(:supporting_document2, :with_file) }

    before do
      sign_in user
      get :show, params: { id: document.id }
    end

    it "assigns the correct document" do
      expect(assigns(:supporting_document)).to eq(document)
    end

    it "finds by exact ID match" do
      expect(SupportingDocument).to receive(:find).with(document.id.to_s)
      get :show, params: { id: document.id }
    end
  end


end
