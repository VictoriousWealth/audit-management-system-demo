require "rails_helper"
include ActiveJob::TestHelper

RSpec.describe ViewAuditsController, type: :controller do
  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }

  let!(:senior_manager) { User.create!(email: "senior.manager@test.com", password: "password123", role: :senior_manager) }
  
  let!(:qa_manager) { User.create!(email: "qa.manager@test.com", password: "password123", role: :qa_manager) }
  let!(:other_qa) { User.create!(email: "other.qa@test.com", password: "password123", role: :qa_manager) }
  
  let!(:lead_auditor) { User.create!(email: "lead.auditor@test.com", password: "password123", role: :auditor) }
  let!(:support_auditor) { User.create!(email: "support.auditor@test.com", password: "password123", role: :auditor) }
  let!(:sme) { User.create!(email: "sme@test.com", password: "password123", role: :sme) }
  let!(:auditor_as_sme) { User.create!(email: "auditor.as.sme@test.com", password: "password123", role: :auditor) }
  let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee, company_id: company.id) }
  let!(:other_auditee) { User.create!(email: "other.auditee@test.com", password: "password123", role: :auditee, company_id: company.id) }
  
  let!(:unassigned_auditor) { User.create!(email: "unassigned.auditor@test.com", password: "password123", role: :auditor) }
  let!(:unassigned_sme) { User.create!(email: "unassigned.sme@test.com", password: "password123", role: :sme) }
  let!(:unassigned_auditee) { User.create!(email: "unassigned.auditee@test.com", password: "password123", role: :auditee) }
  

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

  let!(:assignment_sme) {
    audit.audit_assignments.create!(
      user: sme,
      role: :sme,
      assigned_by: qa_manager.id,
      status: :assigned
    )
  }

  let!(:assignment_auditor_as_sme) {
    audit.audit_assignments.create!(
      user: auditor_as_sme,
      role: :sme,
      assigned_by: qa_manager.id,
      status: :assigned
    )
  }

  let!(:assignment_auditee) {
    audit.audit_assignments.create!(
      user: auditee,
      role: :auditee,
      assigned_by: qa_manager.id,
      status: :assigned
    )
  }

  
  describe "GET #show"  do
    it "allows any Senior manager to view the audit" do
      sign_in senior_manager
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:success)
      sign_out senior_manager
    end

    it "allows the QA manager that assigned the audit to view the audit" do
      sign_in qa_manager
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:success)
      sign_out qa_manager
    end

    it "allows an auditor that's been assigned to the audit as the lead auditor to view the audit" do
      sign_in lead_auditor
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:success)
      sign_out lead_auditor
    end

    it "allows an auditor that's been assigned to the audit as a (support) auditor to view the audit" do
      sign_in support_auditor
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:success)
      sign_out support_auditor
    end
    
    it "allows an sme that's been assigned to the audit as an sme to view the audit" do
      sign_in auditor_as_sme
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:success)
      sign_out auditor_as_sme
    end

    it "allows an auditor that's been assigned to the audit as an sme to view the audit" do
      sign_in auditor_as_sme
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:success)
      sign_out auditor_as_sme
    end

    it "allows the auditee assigned to he audit to view the audit" do
      sign_in auditee
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:success)
      sign_out auditee
    end
    
    it "allows any one auditee from the company of the audit to view the audit" do
      sign_in other_auditee
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:success)
      sign_out other_auditee
    end
    
    it "blocks a qa that did not created the audit to view the audit" do
      sign_in other_qa
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)      
      expect(flash[:alert]).to match(/not authorized/i)
      sign_out other_qa
    end
    
    it "blocks an unassigned auditor to view the audit" do
      sign_in unassigned_auditor
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)      
      expect(flash[:alert]).to match(/not authorized/i)
      sign_out unassigned_auditor
    end

    it "blocks an unassigned sme to view the audit" do
      sign_in unassigned_sme
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)      
      expect(flash[:alert]).to match(/not authorized/i)
      sign_out unassigned_sme
    end

    it "blocks an unassigned auditee to view the audit" do
      sign_in unassigned_auditee
      get :show, params: { id: audit.id }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)      
      expect(flash[:alert]).to match(/not authorized/i)
      sign_out unassigned_auditee
    end
  end

end
