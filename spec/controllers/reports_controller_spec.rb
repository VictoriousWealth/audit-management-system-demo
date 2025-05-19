require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
      # creating test values 
      let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }

      let!(:qa_manager) { User.create!(email: "qa@test.com", password: "password123", role: :qa_manager) }
      let!(:senior_manager) { User.create!(email: "sm@test.com", password: "password123", role: :senior_manager) }
      let!(:lead_auditor) { User.create!(email: "lead@test.com", password: "password123", role: :auditor) }
      let!(:support_auditor) { User.create!(email: "support@test.com", password: "password123", role: :auditor) }
      let!(:unassigned_auditor) { User.create!(email: "none@test.com", password: "password123", role: :auditor) }
      let!(:other_qa) { User.create!(email: "other.qa@test.com", password: "password123", role: :qa_manager) }
      let!(:sme) { User.create!(email: "sme@test.com", password: "password123", role: :sme) }
      let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee) }
    
  
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

  describe "Get #new" do
    before do
      sign_in qa_manager
    end

    it 'returns success and creates a new instance of Report' do
      get :new, params: { audit_id: audit.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:report)).to be_a_new(Report)
    end
  end

  describe "GET #show" do
    before do
      sign_in qa_manager
    end
    let!(:report) { FactoryBot.create(:report, audit: audit, user: qa_manager) }

    it "returns success and assigns the closure letter" do
      get :show, params: { audit_id: audit.id, id: report.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:report)).to eq(report)
    end
  end

  describe "POST #create" do
    before do
      sign_in qa_manager
    end
    let!(:report) { FactoryBot.create(:report, audit: audit, user: qa_manager) }

    it "returns success and creates a new report" do
      post :create, params: { audit_id: audit.id, report: report }
      expect(response).to have_http_status(:redirect)
    end
  end
end