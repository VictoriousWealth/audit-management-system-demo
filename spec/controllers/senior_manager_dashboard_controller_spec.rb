require "rails_helper"
include ActiveJob::TestHelper

RSpec.describe SeniorDashboardController, type: :controller do
  # === Test Setup ===
  let!(:qa_manager) { User.create!(email: "qa.manager@test.com", password: "password123", role: :qa_manager) }
  let!(:auditor) { User.create!(email: "auditor@test.com", password: "password123", role: :auditor) }
  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }
  let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee, company_id: company.id) }
  let!(:senior_manager) { User.create!(email: "senior.manager@test.com", password: "password123", role: :senior_manager) }
  let!(:audit) {
    Audit.create!(
      company_id: company.id,
      audit_type: "internal",
      scheduled_start_date: Date.today - 1.day,
      scheduled_end_date: Date.today + 1.day,
      status: :not_started,
      time_of_creation: Time.zone.now
    )
  }
  let!(:assignment) { AuditAssignment.create!(audit:, user: auditor, role: :auditor, assigned_by: qa_manager.id) }
  let!(:report) { Report.create!(audit: audit, user: qa_manager) }

  before { sign_in senior_manager }
  after { sign_out senior_manager }

  # === General Access ===
  describe "GET #senior_manager - 'general' section"  do
    it "allows an senior_manager to visit their dashboard" do
      get :senior_manager
      expect(response).to have_http_status(:success)
    end
  end

  # === Supporting Documents ===
  describe "GET #senior_manager - documents" do
    let!(:document) do
      SupportingDocument.create!(
        audit: audit,
        user: auditor,
        name: "Evidence File",
        content: "Details about non-compliance",
        file: fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"), "application/pdf")
      )
    end

    it "loads all supporting documents so the senior_manager can see them" do
      get :senior_manager

      docs = assigns(:documents)
      expect(docs).to include(
        hash_including(
          id: document.id,
          title: "Evidence File",
          content: "Details about non-compliance"
        )
      )
    end
  end


  # === Corrective Actions ===
  describe "GET #senior_manager - corrective actions" do
    let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee, company: company) }

    let!(:audit) do
      audit = Audit.create!(
        audit_type: "internal",
        company: company,
        scheduled_start_date: Date.today - 1,
        scheduled_end_date: Date.today + 1,
        status: :in_progress,
        time_of_creation: Time.zone.now
      )
      AuditAssignment.create!(audit: audit, user: auditor, role: :auditor, assigned_by: qa_manager.id)
      AuditAssignment.create!(audit: audit, user: auditee, role: :auditee, assigned_by: qa_manager.id)
      audit
    end

    it "includes pending corrective actions with correct metadata" do
      CorrectiveAction.create!(
        audit: audit,
        action_description: "Update SOP for deviation",
        status: :pending
      )

      get :senior_manager

      expect(assigns(:corrective_actions)).to include(
        hash_including(
          full_description: "Update SOP for deviation",
          truncated_description: "Update SOP f...",
          vendor: company.name,
          progress: 33
        )
      )
    end
    
    it "includes in_progress corrective actions with correct metadata" do
      CorrectiveAction.create!(
        audit: audit,
        action_description: "Update SOP for deviation",
        status: :in_progress
      )

      get :senior_manager

      expect(assigns(:corrective_actions)).to include(
        hash_including(
          full_description: "Update SOP for deviation",
          truncated_description: "Update SOP f...",
          vendor: company.name,
          progress: 66
        )
      )
    end

    it "includes completed corrective actions with correct metadata" do
      CorrectiveAction.create!(
        audit: audit,
        action_description: "Update SOP for deviation",
        status: :completed
      )

      get :senior_manager

      expect(assigns(:corrective_actions)).to include(
        hash_including(
          full_description: "Update SOP for deviation",
          truncated_description: "Update SOP f...",
          vendor: company.name,
          progress: 100
        )
      )
    end
  end


  # === Audit Findings ===
  describe "GET #senior_manager - audit findings" do
    let!(:audit) do
      audit = Audit.create!(
        audit_type: "internal",
        company: company,
        scheduled_start_date: Date.today - 2,
        scheduled_end_date: Date.today + 2,
        status: :completed,
        time_of_creation: Time.zone.now
      )
      AuditAssignment.create!(audit: audit, user: auditor, role: :auditor, assigned_by: qa_manager.id)
      audit
    end

    let!(:report) { Report.create!(audit: audit, user: qa_manager) }

    it "includes all critical findings so that the senior_manager can see them" do
      finding = AuditFinding.create!(
        report: report,
        description: "Major data breach affecting SOPs",
        category: :critical
      )

      get :senior_manager

      findings = assigns(:audit_fidnings)
      expect(findings).to include(
        hash_including(
          id: finding.id,
          full_description: finding.description,
          truncated_description: "Major data b...",
          category: "critical",
          audit_type: "internal"
        )
      )
    end

    it "includes all major findings so thta the senior_manager can see them" do
      finding = AuditFinding.create!(
        report: report,
        description: "Major data breach affecting SOPs",
        category: :major
      )

      get :senior_manager

      findings = assigns(:audit_fidnings)
      expect(findings).to include(
        hash_including(
          id: finding.id,
          full_description: finding.description,
          truncated_description: "Major data b...",
          category: "major",
          audit_type: "internal"
        )
      )
    end

    it "includes all minor findings so that the senior_manager can see them" do
      finding = AuditFinding.create!(
        report: report,
        description: "Major data breach affecting SOPs",
        category: :minor
      )

      get :senior_manager

      findings = assigns(:audit_fidnings)
      expect(findings).not_to include(
        hash_including(
          id: finding.id,
          full_description: finding.description,
          truncated_description: "Major data b...",
          category: "minor",
          audit_type: "internal"
        )
      )
    end
  end


  # === Compliance Score Graph ===
  describe "GET #senior_manager - compliance score graph" do
    let!(:today) { Time.zone.now }

    let!(:internal_audit) {
      a = Audit.create!(audit_type: "internal", company: company, actual_end_date: today,
        score: 85, status: :completed, time_of_creation: today)
      AuditAssignment.create!(audit: a, user: auditor, role: :auditor, assigned_by: qa_manager.id)
      a
    }

    let!(:external_audit) {
      a = Audit.create!(audit_type: "external", company: company, actual_end_date: today,
        score: 70, status: :completed, time_of_creation: today)
      AuditAssignment.create!(audit: a, user: qa_manager, role: :auditor, assigned_by: qa_manager.id)
      a
    }

    it "assigns graph data correctly" do
      get :senior_manager
      graph_data = assigns(:compliance_score_by_day)

      all_audits = graph_data.find { |s| s[:name] == "All Audits" }
      internal_audits = graph_data.find { |s| s[:name] == "Internal" }
      external_audits = graph_data.find { |s| s[:name] == "External" }

      expect(all_audits[:data]).to include([today.strftime("%d-%b-%Y %H:%M"), 85])
      expect(all_audits[:data]).to include([today.strftime("%d-%b-%Y %H:%M"), 70])
      expect(internal_audits[:data]).to include([today.strftime("%d-%b-%Y %H:%M"), 85])
      expect(external_audits[:data]).to include([today.strftime("%d-%b-%Y %H:%M"), 70])
    end
  end

  # === Risk Level Calculation ===
  describe "GET #senior_manager - risk_level" do
    def create_findings(count, category)
      count.times { AuditFinding.create!(report: report, description: "test", category: category) }
    end

    it "returns 'High Risk' for critical findings" do
      create_findings(1, :critical)
      get :senior_manager
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'High Risk' for ≥ 5 major findings" do
      create_findings(5, :major)
      get :senior_manager
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'Medium Risk' for 1–4 major findings" do
      create_findings(3, :major)
      get :senior_manager
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'Medium Risk' for ≥ 5 minor findings" do
      create_findings(5, :minor)
      get :senior_manager
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'Low Risk' for few minor findings" do
      create_findings(2, :minor)
      get :senior_manager
      expect(controller.send(:risk_level, audit)).to eq("Low Risk")
    end
  end

  # === Risk Map Calculation ===
  describe "GET #risk_map" do
    let!(:rpn) do
      VendorRpn.create!(
        company: company,
        time_of_creation: Time.zone.now,
        material_criticality: 3,
        supplier_compliance_history: 3,
        regulatory_approvals: 3,
        supply_chain_complexity: 3,
        previous_supplier_performance: 3,
        contamination_adulteration_risk: 3
      )
    end

    before do
      allow_any_instance_of(VendorRpn).to receive(:calculate_rpn).and_return(85)
      allow(controller).to receive(:risk_level).and_return("High Risk")

      get :senior_manager
    end

    it "assigns a heatmap matrix with correct structure" do
      matrix = assigns(:heatmap_matrix)

      expect(matrix).to be_a(Hash)
      expect(matrix.keys).to match_array(["Low RPN", "Medium RPN", "High RPN"])
      expect(matrix["High RPN"].keys).to match_array(["Low Risk", "Medium Risk", "High Risk"])
    end

    it "increments the correct matrix cell based on risk level and RPN" do
      matrix = assigns(:heatmap_matrix)
      expect(matrix["High RPN"]["High Risk"]).to eq(1)
    end

    it "assigns the correct max heat value" do
      expect(assigns(:max_heat_value)).to eq(1)
    end
  end

  # === RPN (Risk Probability Number) Calculation ===
  describe "#rpn_risk_category" do
    it "returns 'Low RPN' for values 6 to 9" do
      expect(controller.send(:rpn_risk_category, 6)).to eq("Low RPN")
      expect(controller.send(:rpn_risk_category, 9)).to eq("Low RPN")
    end

    it "returns 'Medium RPN' for values 10 to 13" do
      expect(controller.send(:rpn_risk_category, 10)).to eq("Medium RPN")
      expect(controller.send(:rpn_risk_category, 13)).to eq("Medium RPN")
    end

    it "returns 'High RPN' for values outside 6–13" do
      expect(controller.send(:rpn_risk_category, 5)).to eq("High RPN")
      expect(controller.send(:rpn_risk_category, 14)).to eq("High RPN")
      expect(controller.send(:rpn_risk_category, 0)).to eq("High RPN")
    end
  end
end
