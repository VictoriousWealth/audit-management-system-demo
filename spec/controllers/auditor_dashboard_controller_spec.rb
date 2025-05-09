require "rails_helper"
include ActiveJob::TestHelper

RSpec.describe AuditorDashboardController, type: :controller do
  # === Test Setup ===
  let!(:qa_manager) { User.create!(email: "qa.manager@test.com", password: "password123", role: :qa_manager) }
  let!(:auditor) { User.create!(email: "auditor@test.com", password: "password123", role: :auditor) }
  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }
  let!(:audit) {
    Audit.create!(
      company_id: company.id,
      audit_type: "internal",
      scheduled_start_date: Date.today - 1.day,
      scheduled_end_date: Date.today + 1.day,
      status: :in_progress,
      time_of_creation: Time.zone.now
    )
  }
  let!(:assignment) { AuditAssignment.create!(audit:, user: auditor, role: :auditor, assigned_by: qa_manager.id) }
  let!(:report) { Report.create!(audit: audit, user: qa_manager) }

  before { sign_in auditor }
  after { sign_out auditor }

  # === General Access ===
  describe "GET #auditor - 'general' section"  do
    it "allows an auditor to visit their dashboard" do
      get :auditor
      expect(response).to have_http_status(:success)
    end
  end

  # === Supporting Documents ===
  describe "GET #auditor - documents" do
    let!(:document) do
      SupportingDocument.create!(
        audit: audit,
        user: auditor,
        name: "Evidence File",
        content: "Details about non-compliance",
        file: fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"), "application/pdf")
      )
    end

    it "loads supporting documents assigned to the current auditor" do
      get :auditor

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
  describe "GET #auditor - corrective actions" do
    let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee, company: company) }

    before { sign_in auditor }
    after { sign_out auditor }

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

      get :auditor

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

      get :auditor

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

      get :auditor

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
  describe "GET #auditor - audit findings" do
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

    it "includes critical findings assigned to the auditor" do
      finding = AuditFinding.create!(
        report: report,
        description: "Major data breach affecting SOPs",
        category: :critical
      )

      get :auditor

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

    it "includes major findings assigned to the auditor" do
      finding = AuditFinding.create!(
        report: report,
        description: "Major data breach affecting SOPs",
        category: :major
      )

      get :auditor

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

    it "includes minor findings assigned to the auditor" do
      finding = AuditFinding.create!(
        report: report,
        description: "Major data breach affecting SOPs",
        category: :minor
      )

      get :auditor

      findings = assigns(:audit_fidnings)
      expect(findings).to include(
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


  # === Calendar Events ===
  describe "GET #auditor - calendar events" do
    let(:today) { Time.zone.today }

    let!(:audit_due_today) do
      audit = Audit.create!(
        audit_type: "internal",
        company: company,
        scheduled_start_date: today - 1,
        scheduled_end_date: today,
        status: :not_started,
        time_of_creation: Time.zone.now
      )
      AuditAssignment.create!(audit: audit, user: auditor, role: :auditor, assigned_by: qa_manager.id)
      audit
    end

    let!(:audit_overdue) do
      audit = Audit.create!(
        audit_type: "internal",
        company: company,
        scheduled_start_date: today - 5,
        scheduled_end_date: today - 2,
        status: :in_progress,
        time_of_creation: Time.zone.now
      )
      AuditAssignment.create!(audit: audit, user: auditor, role: :auditor, assigned_by: qa_manager.id)
      audit
    end

    it "includes audits due today" do
      get :auditor

      events = assigns(:calendar_events)
      expect(events).to include(
        hash_including(
          title: "🔵1",
          date: today,
          description: "1 audit(s) scheduled to end on #{today}"
        )
      )
    end

    it "includes overdue audits" do
      get :auditor

      events = assigns(:calendar_events)
      expect(events).to include(
        hash_including(
          title: "🔴1",
          date: today,
          description: "1 audit(s) overdue as of today"
        )
      )
    end

    it "includes on-time in-progress audits" do
      get :auditor

      events = assigns(:calendar_events)
      expect(events).to include(
        hash_including(
          title: "🟡1",
          date: today,
          description: "1 audit(s) in progress (on time)"
        )
      )
    end
  end

  # === Compliance Score Graph ===
  describe "GET #auditor - compliance score graph" do
    let!(:today) { Time.zone.now }

    let!(:my_audit) {
      a = Audit.create!(audit_type: "internal", company: company, actual_end_date: today,
        score: 85, status: :completed, time_of_creation: today)
      AuditAssignment.create!(audit: a, user: auditor, role: :auditor, assigned_by: qa_manager.id)
      a
    }

    let!(:other_audit) {
      a = Audit.create!(audit_type: "internal", company: company, actual_end_date: today,
        score: 70, status: :completed, time_of_creation: today)
      AuditAssignment.create!(audit: a, user: qa_manager, role: :auditor, assigned_by: qa_manager.id)
      a
    }

    it "assigns graph data correctly" do
      get :auditor
      graph_data = assigns(:compliance_score_by_day)

      all_audits = graph_data.find { |s| s[:name] == "All Audits" }
      my_audits = graph_data.find { |s| s[:name] == "My Audits" }

      expect(all_audits[:data]).to include([today.strftime("%d-%b-%Y %H:%M"), 85])
      expect(all_audits[:data]).to include([today.strftime("%d-%b-%Y %H:%M"), 70])
      expect(my_audits[:data]).to include([today.strftime("%d-%b-%Y %H:%M"), 85])
      expect(my_audits[:data]).not_to include([today.strftime("%d-%b-%Y %H:%M"), 70])
    end
  end

  # === Risk Level Calculation ===
  describe "GET #auditor - risk_level" do
    def create_findings(count, category)
      count.times { AuditFinding.create!(report: report, description: "test", category: category) }
    end

    it "returns 'High Risk' for critical findings" do
      create_findings(1, :critical)
      get :auditor
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'High Risk' for ≥ 5 major findings" do
      create_findings(5, :major)
      get :auditor
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'Medium Risk' for 1–4 major findings" do
      create_findings(3, :major)
      get :auditor
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'Medium Risk' for ≥ 5 minor findings" do
      create_findings(5, :minor)
      get :auditor
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'Low Risk' for few minor findings" do
      create_findings(2, :minor)
      get :auditor
      expect(controller.send(:risk_level, audit)).to eq("Low Risk")
    end
  end
end
