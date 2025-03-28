require 'rails_helper'

# RSpec test suite for the CreateEditAuditsController
RSpec.describe CreateEditAuditsController, type: :controller do
  # Create a test company for the audit
  let!(:company) { Company.create(name: "Test Company") }

  # Create test users with specific roles
  let!(:lead_auditor) { 
    user = User.create(email: "lead@example.com", password: "password123", role: :auditor)
    puts user.errors.full_messages if user.errors.any? # Print any validation errors
    user
  }
  
  let!(:auditee) { 
    user = User.create(email: "auditee@example.com", password: "password123", role: :auditee)
    puts user.errors.full_messages if user.errors.any?
    user
  }

  let!(:support_auditor) { 
    user = User.create(email: "support@example.com", password: "password123", role: :auditor)
    puts user.errors.full_messages if user.errors.any?
    user
  }

  let!(:sme) { 
    user = User.create(email: "sme@example.com", password: "password123", role: :auditor)
    puts user.errors.full_messages if user.errors.any?
    user
  }

  # Print the total user count to confirm setup
  before do
    puts "Users created: #{User.count}"
  end

  # Test for GET #new action
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  # Test for POST #create action
  describe "POST #create" do
    # Define valid params for creating an audit with nested data
    let(:valid_params) do
      {
        company: { id: company.id },
        audit_assignment: {
          auditee: auditee.id,
          lead_auditor: lead_auditor.id,
          support_auditor: [support_auditor.id],
          sme: [sme.id]
        },
        audit: {
          audit_type: "internal",
          scheduled_start_date: "2024-01-01T00:00",
          scheduled_end_date: "2024-01-10T00:00",
          actual_start_date: "2024-01-02T00:00",
          actual_end_date: "2024-01-09T00:00"
        },
        audit_detail: {
          scope: "Scope",
          objectives: "Objective",
          purpose: "Purpose",
          boundaries: "Boundaries"
        },
        audit_standard: { standard: ["ISO 9001"] },
        commit: "Save Changes"
      }
    end

    # Case 1: User clicks "Close Audit" instead of submitting
    it "redirects if 'Close Audit' is clicked" do
      post :create, params: valid_params.merge(commit: "Close Audit")
      expect(response).to redirect_to(create_edit_audits_path)
      expect(flash[:notice]).to eq("Audit creation cancelled. No data was saved.")
    end

    # Case 2: Required fields are missing (company id), so form is re-rendered
    it "does not save with missing required fields" do
      post :create, params: valid_params.deep_merge(company: { id: nil })
      expect(response).to render_template(:new)
      expect(flash.now[:alert]).to eq("Please fill in all required fields before submitting.")
    end

    # Case 3: Full successful creation of audit and all associated records
    it "creates audit and associated records successfully" do
      expect(Company.count).to eq(1)
      expect(User.count).to eq(4)

      expect {
        post :create, params: valid_params
      }.to change(Audit, :count).by(1) # 1 audit
       .and change(AuditAssignment, :count).by(4) # auditee, lead, support, SME
       .and change(AuditStandard, :count).by(1) # ISO 9001
       
      expect(response).to redirect_to(edit_create_edit_audit_path(Audit.last))
    end

    # Case 4: SME and support_auditor are left blank - still should create audit
    it "does not raise error if support auditor or SME are blank" do
      params = valid_params.deep_merge(
        audit_assignment: {
          auditee: auditee.id,
          lead_auditor: lead_auditor.id,
          support_auditor: [""],
          sme: [""]
        }
      )

      expect {
        post :create, params: params
      }.to change(Audit, :count).by(1) # Audit still gets created
    end
  end

  # Test for GET #edit action
  describe "GET #edit" do
    let!(:audit) { Audit.create(company_id: company.id, audit_type: "internal", scheduled_start_date: Date.today, scheduled_end_date: Date.today + 1) }
    let!(:audit_detail) { AuditDetail.create(audit_id: audit.id, scope: "Scope", objectives: "Obj", purpose: "Purp", boundaries: "Bound") }

    it "renders the edit page with populated data" do
      get :edit, params: { id: audit.id }
      expect(response).to render_template(:edit)
      expect(assigns(:audit)).to eq(audit)
      expect(assigns(:scope)).to eq("Scope") # Confirm data is passed to view
    end
  end

  # Test for PATCH #update action
  describe "PATCH #update" do
    let!(:audit) { Audit.create(company_id: company.id, audit_type: "internal", scheduled_start_date: Date.today, scheduled_end_date: Date.today + 1) }
    let!(:audit_detail) { AuditDetail.create(audit_id: audit.id, scope: "Scope", objectives: "Obj", purpose: "Purp", boundaries: "Bound") }

    # Case 1: Close audit is clicked - redirect without saving
    it "redirects if 'Close Audit' is clicked" do
      patch :update, params: { id: audit.id, commit: "Close Audit" }
      expect(response).to redirect_to(create_edit_audits_path)
    end

    # Case 2: Missing fields cause update to fail and re-render the edit form
    it "fails update with missing fields and re-renders edit" do
      patch :update, params: {
        id: audit.id,
        company: { id: nil },
        audit_assignment: { auditee: nil, lead_auditor: nil },
        audit: {},
        audit_detail: {},
        audit_standard: { standard: [""] }
      }
      expect(response).to render_template(:edit)
      expect(flash.now[:alert]).to match(/Invalid request changes/)
    end
  end
end
