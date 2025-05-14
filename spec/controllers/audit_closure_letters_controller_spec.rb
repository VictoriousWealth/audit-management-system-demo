require 'rails_helper'

RSpec.describe AuditClosureLettersController, type: :controller do

  # creating test values 
  let!(:qa_manager) { User.create!(email: "qa@test.com", password: "password123", role: :qa_manager) }
  let!(:lead_auditor) { User.create!(email: "lead@test.com", password: "password123", role: :auditor) }
  let!(:support_auditor) { User.create!(email: "support@test.com", password: "password123", role: :auditor) }
  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }
  let!(:audit) { create(:audit, company: company) }
  let!(:audit_closure_letter) { create(:audit_closure_letter, audit: audit, user: qa_manager) }

  let!(:assignment_lead) {
    audit.audit_assignments.create!(
      user: lead_auditor,
      role: :lead_auditor,
      assigned_by: qa_manager.id,
      status: :assigned
    )
  }

  let!(:assignment_support) {
    audit.audit_assignments.create!(
      user: support_auditor,
      role: :auditor,
      assigned_by: qa_manager.id,
      status: :assigned
    )
  }

  let(:valid_params) do
    {
      audit_id: audit.id,
      audit_closure_letter: {
        overall_compliance: "Compliant",
        summary_statement: "Summary text",
        auditee_acknowledged: "1",
        auditor_acknowledged: "1"
      }
    }
  end

  before do
    sign_in qa_manager
  end

  describe "GET #index" do
    it "returns success and assigns closure letters" do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:audit_closure_letters)).to include(audit_closure_letter)
    end
  end

  describe "GET #new" do
    it 'returns success and assigns the closure letter' do
      get :new, params: { audit_id: audit.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:audit_closure_letter)).to be_a_new(AuditClosureLetter)
    end
  end

  describe "GET #show" do
    it "returns success and assigns the closure letter" do
      get :show, params: { audit_id: audit.id, id: audit_closure_letter.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:audit_closure_letter)).to eq(audit_closure_letter)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do

      before { audit_closure_letter.destroy }

      it "creates a new closure letter and redirects" do
        expect {
          post :create, params: valid_params
        }.to change(AuditClosureLetter, :count).by(1)

        expect(response).to redirect_to(audit_closure_letters_path)
      end
    end

    context "with invalid parameters" do
      it "raises ParameterMissing error" do
        expect {
          post :create, params: { audit_id: audit.id }
        }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when save fails" do
      before do
        allow_any_instance_of(AuditClosureLetter).to receive(:save).and_return(false)
      end

      before { audit_closure_letter.destroy }
    
      it "renders new template" do
        post :create, params: { audit_id: audit.id, audit_closure_letter: { overall_compliance: "something" } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "DELETE #destroy" do
    it "deletes the closure letter and redirects" do
      audit_closure_letter
      delete :destroy, params: { audit_id: audit.id, id: audit_closure_letter.id }
      expect(response).to redirect_to(audit_closure_letters_path(audit))
    end

    context "when destroy fails" do
      it "redirects with an alert" do
        audit_closure_letter
        allow_any_instance_of(AuditClosureLetter).to receive(:destroy).and_return(false)

        delete :destroy, params: { audit_id: audit.id, id: audit_closure_letter.id }
        expect(response).to redirect_to(audit_closure_letters_path(audit))
        expect(flash[:alert]).to eq("Failed to delete the closure letter.")
      end
    end      
  end
end