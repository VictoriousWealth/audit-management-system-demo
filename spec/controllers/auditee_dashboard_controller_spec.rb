require "rails_helper"
include ActiveJob::TestHelper

RSpec.describe AuditeeDashboardController, type: :controller do
  # === Test Setup ===
  let!(:qa_manager) { User.create!(email: "qa.manager@test.com", password: "password123", role: :qa_manager) }
  let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee, company_id: company.id) }
  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }
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
  let!(:assignment) { AuditAssignment.create!(audit:, user: auditee, role: :auditee, assigned_by: qa_manager.id) }
  let!(:report) { Report.create!(audit: audit, user: qa_manager) }

  before { sign_in auditee }
  after { sign_out auditee }

  # === General Access ===
  describe "GET #auditee - 'general' section"  do
    it "allows an auditee to visit their dashboard" do
      get :auditee
      expect(response).to have_http_status(:success)
    end
  end

  # === Supporting Documents ===
  describe "GET #auditee - supporting documents section"  do
    it "loads supporting documents related to the auditee" do
      doc = SupportingDocument.create!(
        audit: audit,
        user: auditee,
        name: "Test Doc",
        content: "Test content",
        file: fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"), "application/pdf")
      )

      get :auditee
      documents = assigns(:documents)
      expect(documents).to include(hash_including(id: doc.id, title: "Test Doc", content: "Test content"))
    end
  end

  # === Corrective Actions ===
  describe "GET #auditee - corrective actions section" do
    it "loads pending corrective actions related to the auditee" do
      corrective_action = CorrectiveAction.create!(
        audit: audit,
        action_description: "Fix broken SOP",
        status: :pending
      )

      get :auditee
      corrective_actions = assigns(:corrective_actions)
      expect(corrective_actions).to include(
        hash_including(id: corrective_action.id, progress: 33)
      )
    end

    it "loads in_progress corrective actions related to the auditee" do
      corrective_action = CorrectiveAction.create!(
        audit: audit,
        action_description: "Fix broken SOP",
        status: :in_progress
      )

      get :auditee
      corrective_actions = assigns(:corrective_actions)
      expect(corrective_actions).to include(hash_including(id: corrective_action.id, progress: 66))
    end

    it "loads completed corrective actions related to the auditee" do
      corrective_action = CorrectiveAction.create!(
        audit: audit,
        action_description: "Fix broken SOP",
        status: :completed
      )

      get :auditee
      corrective_actions = assigns(:corrective_actions)
      expect(corrective_actions).to include(hash_including(id: corrective_action.id, progress: 100))
    end
  end

  # === Audit Findings ===
  describe "GET #auditee - audit findings section" do
    it "loads critical audit findings" do
      finding = AuditFinding.create!(report: report, description: "High-risk finding", category: :critical)

      get :auditee
      findings = assigns(:audit_findings)
      expect(findings).to include(hash_including(id: finding.id, category: "critical"))
    end

    it "loads major audit findings" do
      finding = AuditFinding.create!(report: report, description: "High-risk finding", category: :major)

      get :auditee
      findings = assigns(:audit_findings)
      expect(findings).to include(hash_including(id: finding.id, category: "major"))
    end

    it "loads minor audit findings" do
      finding = AuditFinding.create!(report: report, description: "High-risk finding", category: :minor)

      get :auditee
      findings = assigns(:audit_findings)
      expect(findings).to include(hash_including(id: finding.id, category: "minor"))
    end
  end

  # === Calendar Events ===
  describe "GET #auditee - calendar events section" do
    let(:today) { Time.zone.today }

    let!(:audit_due_today) {
      a = Audit.create!(audit_type: "internal", company: company,
        scheduled_start_date: today - 2, scheduled_end_date: today,
        status: :not_started, time_of_creation: Time.current)
      AuditAssignment.create!(audit: a, user: auditee, role: :auditee, assigned_by: qa_manager.id)
      a
    }

    let!(:audit_overdue) {
      a = Audit.create!(audit_type: "internal", company: company,
        scheduled_start_date: today - 5, scheduled_end_date: today - 2,
        status: :in_progress, time_of_creation: Time.current)
      AuditAssignment.create!(audit: a, user: auditee, role: :auditee, assigned_by: qa_manager.id)
      a
    }

    let!(:audit_on_time) {
      a = Audit.create!(audit_type: "internal", company: company,
        scheduled_start_date: today, scheduled_end_date: today + 3,
        status: :in_progress, time_of_creation: Time.current)
      AuditAssignment.create!(audit: a, user: auditee, role: :auditee, assigned_by: qa_manager.id)
      a
    }

    it "loads audits due today" do
      get :auditee
      events = assigns(:calendar_events)
      expect(events).to include(hash_including(title: "🔵1", date: today))
    end

    it "loads overdue audits" do
      get :auditee
      events = assigns(:calendar_events)
      expect(events).to include(hash_including(title: "🔴1", date: today))
    end

    it "loads on-time audits" do
      get :auditee
      events = assigns(:calendar_events)
      expect(events).to include(hash_including(title: "🟡1", date: today))
    end
  end

  # === Compliance Score Graph ===
  describe "GET #auditee - compliance score graph" do
    let!(:today) { Time.zone.now }

    let!(:my_audit) {
      a = Audit.create!(audit_type: "internal", company: company, actual_end_date: today,
        score: 85, status: :completed, time_of_creation: today)
      AuditAssignment.create!(audit: a, user: auditee, role: :auditee, assigned_by: qa_manager.id)
      a
    }

    let!(:other_audit) {
      a = Audit.create!(audit_type: "internal", company: company, actual_end_date: today,
        score: 70, status: :completed, time_of_creation: today)
      AuditAssignment.create!(audit: a, user: qa_manager, role: :auditor, assigned_by: qa_manager.id)
      a
    }

    it "assigns graph data correctly" do
      get :auditee
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
  describe "GET #auditee - risk_level" do
    def create_findings(count, category)
      count.times { AuditFinding.create!(report: report, description: "test", category: category) }
    end

    it "returns 'High Risk' for critical findings" do
      create_findings(1, :critical)
      get :auditee
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'High Risk' for ≥ 5 major findings" do
      create_findings(5, :major)
      get :auditee
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'Medium Risk' for 1–4 major findings" do
      create_findings(3, :major)
      get :auditee
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'Medium Risk' for ≥ 5 minor findings" do
      create_findings(5, :minor)
      get :auditee
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'Low Risk' for few minor findings" do
      create_findings(2, :minor)
      get :auditee
      expect(controller.send(:risk_level, audit)).to eq("Low Risk")
    end
  end
end
