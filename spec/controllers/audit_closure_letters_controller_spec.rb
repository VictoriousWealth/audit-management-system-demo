require 'rails_helper'

RSpec.describe AuditClosureLettersController, type: :controller do

  # creating test values 
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:audit) { create(:audit, company: company) }
  let(:audit_closure_letter) { create(:audit_closure_letter, audit: audit, user: user) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns success and assigns closure letters" do
      audit_closure_letter
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
  end

  describe "DELETE #destroy" do
    it "deletes the closure letter and redirects" do
      audit_closure_letter
      delete :destroy, params: { audit_id: audit.id, id: audit_closure_letter.id }
      expect(response).to redirect_to(audit_closure_letters_path(audit))
    end
  end
end