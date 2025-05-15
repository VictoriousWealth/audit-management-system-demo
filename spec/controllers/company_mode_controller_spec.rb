require "rails_helper"
include ActiveJob::TestHelper

RSpec.describe CompanyModeController, type: :controller do
  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }
  let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee, company: company) }

  # --- Scheduled Audit (not_started) ---
  let!(:scheduled_audit) {
    Audit.create!(
      audit_type: "internal",
      company: company,
      scheduled_start_date: Date.today + 3,
      scheduled_end_date: Date.today + 5,
      status: :not_started,
      time_of_creation: Time.current
    )
  }
  let!(:scheduled_assignment) {
    AuditAssignment.create!(audit: scheduled_audit, user: auditee, role: :auditee, assigned_by: auditee.id)
  }

  # --- In Progress Audit (this week) ---
  let!(:in_progress_audit) {
    Audit.create!(
      audit_type: "internal",
      company: company,
      scheduled_start_date: Date.today - 2,
      actual_start_date: Date.today - 1,
      scheduled_end_date: Date.today + 2,
      status: :in_progress,
      time_of_creation: Time.current
    )
  }
  let!(:in_progress_assignment) {
    AuditAssignment.create!(audit: in_progress_audit, user: auditee, role: :auditee, assigned_by: auditee.id)
  }

  # --- Completed Audit (today, with score, for compliance graph) ---
  let!(:completed_audit) {
    Audit.create!(
      audit_type: "internal",
      company: company,
      scheduled_start_date: Date.today - 5,
      scheduled_end_date: Date.today - 2,
      actual_start_date: Date.today - 5,
      actual_end_date: Time.zone.now,  # today for daily graph
      status: :completed,
      score: 85,
      time_of_creation: Time.current
    )
  }
  let!(:completed_assignment) {
    AuditAssignment.create!(audit: completed_audit, user: auditee, role: :auditee, assigned_by: auditee.id)
  }

  # --- Supporting models for completed_audit ---
  let!(:report) { Report.create!(audit: completed_audit, user: auditee) }
  let!(:finding1) { AuditFinding.create!(report: report, description: "Contamination issue", category: :minor) }
  let!(:finding2) { AuditFinding.create!(report: report, description: "Contamination issue", category: :major) }
  let!(:finding3) { AuditFinding.create!(report: report, description: "Contamination issue", category: :critical) }
  let!(:corrective_action1) { CorrectiveAction.create!(audit: completed_audit, action_description: "Fix SOP", status: :pending) }
  let!(:corrective_action2) { CorrectiveAction.create!(audit: completed_audit, action_description: "Fix SOP", status: :in_progress) }
  let!(:corrective_action3) { CorrectiveAction.create!(audit: completed_audit, action_description: "Fix SOP", status: :completed) }
  let!(:supporting_document) {
    SupportingDocument.create!(
      audit: completed_audit,
      user: auditee,
      name: "Doc1",
      content: "Test content",
      file: fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"), "application/pdf")
    )
  }
  let!(:vendor_rpn) {
    VendorRpn.create!(
      company: company,
      time_of_creation: Time.zone.today,
      material_criticality: 2,
      supplier_compliance_history: 2,
      regulatory_approvals: 2,
      supply_chain_complexity: 2,
      previous_supplier_performance: 2,
      contamination_adulteration_risk: 2
    )
  }


  before { sign_in auditee }
  after { sign_out auditee }

  describe "GET #company_mode" do
    it "returns success and assigns all expected instance variables" do
      get :company_mode

      expect(response).to have_http_status(:success)
      expect(assigns(:completed_audits)).to be_present
      expect(assigns(:scheduled_audits)).to be_present
      expect(assigns(:in_progress_audits)).to be_present
      expect(assigns(:pie_chart_data)).to be_present
      expect(assigns(:bar_chart_data)).to be_present
      expect(assigns(:compliance_score_by_day)).to be_present
      expect(assigns(:compliance_score_by_week)).to be_present
      expect(assigns(:compliance_score_by_month)).to be_present
      expect(assigns(:compliance_score_all)).to be_present
      expect(assigns(:audit_findings)).to be_present
      expect(assigns(:corrective_actions)).to be_present
      expect(assigns(:documents)).to be_present
      expect(assigns(:vendor_rpns)).to be_present
      expect(assigns(:audit_scores)).to be_present
      expect(assigns(:risk_levels)).to be_present
    end
  end

  describe "#risk_level" do
    let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }
    let!(:auditee) { User.create!(email: "auditee@example.com", password: "password123", role: :auditee, company: company) }

    def create_audit_with_findings(category, count)
      audit = Audit.create!(
        company: company,
        audit_type: "internal",
        scheduled_start_date: Date.today,
        scheduled_end_date: Date.today + 1,
        actual_start_date: Date.today - 1,
        actual_end_date: Date.today,
        status: :completed,
        score: 80,
        time_of_creation: Time.current
      )

      assignment = AuditAssignment.create!(audit: audit, user: auditee, role: :auditee, assigned_by: auditee.id)
      report = Report.create!(audit: audit, user: auditee)

      count.times do
        AuditFinding.create!(report: report, description: "#{category} issue", category: category)
      end

      audit
    end

    it "returns 'High Risk' for 1 critical finding" do
      audit = create_audit_with_findings(:critical, 1)
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'High Risk' for 5 major findings" do
      audit = create_audit_with_findings(:major, 5)
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'Medium Risk' for 5 minor findings" do
      audit = create_audit_with_findings(:minor, 5)
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'Medium Risk' for 1 major finding" do
      audit = create_audit_with_findings(:major, 1)
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'Low Risk' for 4 minor findings" do
      audit = create_audit_with_findings(:minor, 4)
      expect(controller.send(:risk_level, audit)).to eq("Low Risk")
    end

    it "returns 'Low Risk' for 0 findings" do
      audit = Audit.create!(
        company: company,
        audit_type: "internal",
        scheduled_start_date: Date.today,
        scheduled_end_date: Date.today + 1,
        actual_start_date: Date.today - 1,
        actual_end_date: Date.today,
        status: :completed,
        score: 80,
        time_of_creation: Time.current
      )
      Report.create!(audit: audit, user: auditee)
      expect(controller.send(:risk_level, audit)).to eq("Low Risk")
    end
  end

  describe "before_action :ensure_auditee!" do
    let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }
  
    let!(:auditee) { User.create!(email: "auditee@example.com", password: "password123", role: :auditee, company: company) }
    let!(:qa_manager) { User.create!(email: "qa@example.com", password: "password123", role: :qa_manager, company: company) }
  
    controller(CompanyModeController) do
      def index
        render plain: "Access granted"
      end
    end
  
    context "when current_user is an auditee" do
      before { sign_in auditee }
  
      it "allows access" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Access granted")
      end
    end
  
    context "when current_user is not an auditee" do
      before { sign_in qa_manager }
  
      it "redirects to dashboard and sets flash" do
        get :index
        expect(response).to redirect_to(dashboard_index_path)
        expect(flash[:alert]).to eq("Access denied: Only auditees can view that page.")
      end
    end
  end
  

end
