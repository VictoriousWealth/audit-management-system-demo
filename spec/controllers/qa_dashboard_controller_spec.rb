# Requiring and including helpers
require "rails_helper"
include ActiveJob::TestHelper
require 'active_support/testing/time_helpers'

# Tests for the QA Dashboard Controller
RSpec.describe QaDashboardController, type: :controller do
  # Including a helper to jump time
  include ActiveSupport::Testing::TimeHelpers
  
  # Creating test entries
  let!(:qa_manager) { User.create!(email: "qa.manager@test.com", password: "password123", role: :qa_manager) }
  let!(:auditor) { User.create!(email: "auditor@test.com", password: "password123", role: :auditor) }
  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }
  let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee, company_id: company.id) }
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
  let!(:assignment) { AuditAssignment.create!(audit: audit, user: auditor, role: :auditor, assigned_by: qa_manager.id) }
  let!(:report) { Report.create!(audit: audit, user: qa_manager) }

  # Actions to perform before and after any test
  before { sign_in qa_manager }
  after { sign_out qa_manager }

  # Test for rendering the dashboard
  describe "GET #qa_manager" do
    it "renders the dashboard successfully" do
      # Calling the parent function
      get :qa_manager
      expect(response).to have_http_status(:success)
    end
  end

  # Test for assigning supporting documents
  describe "documents section" do
    # Creating a document entry
    let!(:document) { create(:document, name: "Evidence", content: "Supporting compliance data") }

    it "assigns supporting documents" do
      # Calling the parent function
      get :qa_manager

      # Expecting @documents to include certain fields
      expect(assigns(:documents)).to include(
        hash_including(
          id: document.id,
          title: document.name,
          content: document.content
        )
      )
    end
  end

  # Tests for the corrective actions section
  describe "corrective actions section" do
    # Creating necessary entries
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

    it "includes pending corrective actions" do
      # Creating a corrective action entry
      CorrectiveAction.create!(
        audit: audit,
        action_description: "Update SOP for deviation",
        status: :pending
      )

      # Calling the parent function
      get :qa_manager

      # Expecting @corrective_actions to include certain fields and values
      # with progress => 33
      expect(assigns(:corrective_actions)).to include(
        hash_including(
          full_description: "Update SOP for deviation",
          truncated_description: "Update SOP f...",
          vendor: company.name,
          progress: 33
        )
      )
    end

    it "includes in progress corrective actions" do
      # Creating a corrective action entry
      CorrectiveAction.create!(
        audit: audit,
        action_description: "Update SOP for deviation",
        status: :in_progress
      )

      # Calling the parent function
      get :qa_manager

      # Expecting @corrective actions to include certain fields and values
      # with progress => 66
      expect(assigns(:corrective_actions)).to include(
        hash_including(
          full_description: "Update SOP for deviation",
          truncated_description: "Update SOP f...",
          vendor: company.name,
          progress: 66
        )
      )
    end

    it "includes completed corrective actions" do
      # Creating a corrective action entry
      ca = create(:corrective_action, audit: audit, status: :completed, action_description: "Update SOP for deviation")

      # Calling the parent function
      get :qa_manager

       # Expecting @corrective actions to include certain fields and values
      # with progress => 100
      expect(assigns(:corrective_actions)).to include(
        hash_including(
          full_description: ca.action_description,
          truncated_description: "Update SOP f...",
          vendor: company.name,
          progress: 100
        )
      )
    end
  end

  # Test for the audit findings section
  describe "audit findings section" do
    # Creating the necessary entries
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

    it "shows critical findings" do
      # Creating an audit finding
      finding = AuditFinding.create!(
        report: report,
        description: "Major data breach affecting SOPs",
        category: :critical
      )

      # Calling the parent function
      get :qa_manager

      # Expecting the findings to include certain fields and values
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
  end

  # Tests for the calendar section
  describe "calendar events" do
    # Creating dates
    let!(:today) { Date.new(2025, 5, 14) }
    let!(:tomorrow) { today + 1.day }
    let!(:yesterday) { today - 1.day }
  
    # Actions to run before the tests
    before do
      # Jumping date to today
      travel_to today do
        # Creating an audit scheduled to end tomorrow
        Audit.create!(
          audit_type: "internal",
          company: company,
          scheduled_end_date: tomorrow,
          scheduled_start_date: today,
          status: :not_started,
          time_of_creation: Time.zone.now
        )
  
        # Creating an overdue audit
        Audit.create!(
          audit_type: "external",
          company: company,
          scheduled_end_date: yesterday,
          scheduled_start_date: today - 5,
          status: :in_progress,
          time_of_creation: Time.zone.now
        )
  
        # Creating an in-progress audit
        Audit.create!(
          audit_type: "external",
          company: company,
          scheduled_end_date: today,
          scheduled_start_date: today,
          status: :in_progress,
          time_of_creation: Time.zone.now
        )
  
        # Calling the parent function
        get :qa_manager
      end
    end

    # Actions to run after the tests
    after do
      # Jumping back to the time before the travel_to
      travel_back
    end

    # Getting the number of overdue audits
    let(:overdue_count) do
      Audit.where.not(status: :completed).where("scheduled_end_date < ?", Time.zone.today).count
    end

     # Getting the number of in progress audits
    let(:in_progress_count) do
      Audit.where.not(status: :in_progress).where("scheduled_end_date > ?", Time.zone.today).count
    end
  
    it "assigns calendar events for scheduled end dates" do
      # Getting events that end tomorrow and start with 🔵
      event = assigns(:calendar_events).find { |e| e[:date].to_date == tomorrow && e[:title].start_with?("🔵") }

      # Expecting the event to have certain fields and values
      expect(event).to match(
        title: "🔵1",
        date: tomorrow,
        allDay: true,
        textColor: "#000",
        description: "1 audit(s) scheduled to end on #{tomorrow}"
      )
    end
  
    it "assigns calendar events for overdue audits" do
      # Getting events that end today and start with 🔴
      event = assigns(:calendar_events).find { |e| e[:date].to_date == today && e[:title].start_with?("🔴") }
      
       # Expecting the event to have certain fields and values
      expect(event).to include(
        title: "🔴#{overdue_count}",
        description: "#{overdue_count} audit(s) overdue as of today"
      )
    end
  
    it "assigns calendar events for in-progress audits" do
      # Getting events that end today and start with 🟡
      event = assigns(:calendar_events).find { |e| e[:date].to_date == today && e[:title].start_with?("🟡") }
      
      # Expecting the event to have certain fields and values
      expect(event).to include(
        title: "🟡#{in_progress_count}",
        description: "#{in_progress_count} audit(s) in progress"
      )
    end
  end
   
  # Tests for the compliance score graph section
  describe "compliance score graph section" do
    # Creating a variable for today's time
    let!(:today) { Time.zone.now }

    # Creating an internal audit
    let!(:internal_audit) {
      a = Audit.create!(audit_type: "internal", company: company, actual_end_date: today,
        score: 85, status: :completed, time_of_creation: today)
      AuditAssignment.create!(audit: a, user: auditor, role: :auditor, assigned_by: qa_manager.id)
    }

    # Creating an external audit
    let!(:external_audit) {
      a = Audit.create!(audit_type: "external", company: company, actual_end_date: today,
        score: 70, status: :completed, time_of_creation: today)
      AuditAssignment.create!(audit: a, user: qa_manager, role: :auditor, assigned_by: qa_manager.id)
    }


    it "assigns compliance score data correctly" do
      # Calling the parent function
      get :qa_manager

      # Getting @compliance_score_by_day
      graph_data = assigns(:compliance_score_by_day)

      # Finding all audits, internal audits, and external audits
      all_audits = graph_data.find { |s| s[:name] == "All Audits" }
      internal_audits = graph_data.find { |s| s[:name] == "Internal" }
      external_audits = graph_data.find { |s| s[:name] == "External" }

      # Expecting the audits to include certain fields and values
      expect(all_audits[:data]).to include([today.strftime("%d-%b-%Y"), 85])
      expect(all_audits[:data]).to include([today.strftime("%d-%b-%Y"), 70])
      expect(internal_audits[:data]).to include([today.strftime("%d-%b-%Y"), 85])
      expect(external_audits[:data]).to include([today.strftime("%d-%b-%Y"), 70])
    end
  end

  # Tests for the risk_level helper function
  describe "risk level helper" do
    # Returns created findings
    # Takes an integer "count" for the number of findings to create
    # and "category" for the category of the finding
    def create_findings(count, category)
      count.times { create(:audit_finding, report:, category:, description: "Test finding") }
    end

    it "returns 'High Risk' for critical findings" do
      # Creating 1 critical finding
      create_findings(1, :critical)

      # Calling the parent function
      get :qa_manager

       # Expecting the risk_level function to return "High Risk"
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'Medium Risk' for 3 major findings" do
      # Creating 3 major findings
      create_findings(3, :major)

      # Calling the parent function
      get :qa_manager

      # Expecting the risk_level function to return "Medium Risk"
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'High Risk' for 7 major findings" do
      # Creating 7 major findings
      create_findings(7, :major)

      # Calling the parent function
      get :qa_manager

      # Expecting the risk_level function to return "High Risk"
      expect(controller.send(:risk_level, audit)).to eq("High Risk")
    end

    it "returns 'Medium Risk' for 7 minor findings" do
      # Creating 7 minor findings
      create_findings(7, :minor)

      # Calling the parent function
      get :qa_manager

      # Expecting the risk_level function to return "Medium Risk"
      expect(controller.send(:risk_level, audit)).to eq("Medium Risk")
    end

    it "returns 'Low Risk' for 2 minor findings" do
      # Creating 2 minor findings
      create_findings(2, :minor)

      # Calling the parent function
      get :qa_manager

      # Expecting the risk_level function to return "Low Risk"
      expect(controller.send(:risk_level, audit)).to eq("Low Risk")
    end
  end
end
