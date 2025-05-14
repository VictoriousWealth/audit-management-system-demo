require 'rails_helper'

RSpec.describe AuditRequestLettersController, type: :controller do
  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }
  let!(:qa_manager) { User.create!(email: "qa@test.com", password: "password123", role: :qa_manager) }
  let!(:senior_manager) { User.create!(email: "sm@test.com", password: "password123", role: :senior_manager) }
  let!(:lead_auditor) { User.create!(email: "lead@test.com", password: "password123", role: :auditor) }
  let!(:support_auditor) { User.create!(email: "support@test.com", password: "password123", role: :auditor) }
  let!(:sme) { User.create!(email: "sme@test.com", password: "password123", role: :sme) }
  let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee) }
  let(:audit_request_letter) { create(:audit_request_letter, audit: audit, user: qa_manager) }


  let!(:audit) {
    Audit.create!(
      company_id: company.id,
      audit_type: "internal",
      scheduled_start_date: Date.today,
      scheduled_end_date: Date.today + 1.day,
      status: :not_started,
      time_of_creation: Time.now
    )
  }

  let!(:audit_detail) {
    AuditDetail.create!(
      audit: audit,
      scope: "scope",
      objectives: "objectives",
      purpose: "purpose",
      boundaries: "boundaries"
    )
  }

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
  before do
    sign_in qa_manager
  end

  # describe "Get #new" do
  #   it "renders the new template and return success" do
  #     get :new, params: { audit_id: audit.id }
  #     expect(response).to have_http_status(:success)
  #     expect(assigns(:audit_request_letter)).to be_a_new(AuditRequestLetter)
  #   end
  # end

  # describe "GET #show" do
  #   it "returns success and assigns the closure letter" do
  #     get :show, params: { audit_id: audit.id}
  #     expect(response).to have_http_status(:success)
  #     expect(assigns(:audit_request_letter)).to eq(audit_request_letter)
  #   end
  # end

  describe 'GET #new' do
    it 'returns success and initializes AuditRequestLetter' do
      get :new, params: { audit_id: audit.id }
      expect(response).to have_http_status(:ok)
      expect(assigns(:audit_request_letter)).to be_a_new(AuditRequestLetter)
      expect(assigns(:today_date)).to eq(Date.today.strftime("%d/%m/%Y"))
    end
  end

  describe 'POST #create' do
    it 'creates or updates the AuditRequestLetter and redirects to preview' do
      post :create, params: {
        audit_id: audit.id,
        audit_scope: "Test Scope",
        audit_purpose: "Test Purpose",
        audit_objectives: "Test Objectives",
        audit_boundaries: "Test Boundaries",
        audit_location: "Test Location",
        audit_criteria: "Test Criteria"
      }

      expect(response).to redirect_to(preview_audit_audit_request_letters_path(audit))
      expect(flash[:notice]).to eq("Audit Request Letter created successfully.")
      expect(AuditRequestLetter.last.user).to eq(qa_manager)
    end
  end

  describe 'GET #show' do
    it 'redirects if letter is missing' do
      get :show, params: { audit_id: audit.id }
          
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_audit_audit_request_letters_path(audit))
      expect(flash[:alert]).to eq("Audit Request Letter not found.")
    end

    context 'when the letter exists' do
    let!(:audit_request_letter) { FactoryBot.create(:audit_request_letter, audit: audit) }

      it 'renders the letter' do
        get :show, params: { audit_id: audit_request_letter.audit.id }
        
        expect(response).to have_http_status(:ok)
        expect(assigns(:audit_request_letter)).to eq(audit_request_letter)
      end
    end
  end

  describe 'POST #verify' do
    it 'verifies an existing letter' do
      create(:audit_request_letter, audit: audit)
      post :verify, params: { audit_id: audit.id }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(audit_audit_request_letters_path(audit))
      expect(flash[:notice]).to eq("Audit Request Letter verified successfully.")
    end

    it 'redirects if no letter exists' do
      post :verify, params: { audit_id: audit.id }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_audit_audit_request_letters_path(audit))
      expect(flash[:alert]).to eq("Audit Request Letter not found.")
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys an existing letter' do
      create(:audit_request_letter, audit: audit)
      delete :destroy, params: { audit_id: audit.id }

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(new_audit_audit_request_letters_path(audit))
      expect(flash[:notice]).to eq("Audit Request Letter was successfully destroyed.")
    end
  end
end