require 'rails_helper'

# Test suite for the CreateEditAuditsController
RSpec.describe CreateEditAuditsController, type: :controller do
  # Setup test data
  let!(:company) { Company.create(name: "Test Company") }

  # Creating users with different roles, printing errors if creation fails
  let!(:lead_auditor) do
    user = User.create(email: "lead@example.com", password: "password123", role: :auditor)
    puts user.errors.full_messages if user.errors.any?
    user
  end

  let!(:auditee) do
    user = User.create(email: "auditee@example.com", password: "password123", role: :auditee)
    puts user.errors.full_messages if user.errors.any?
    user
  end

  let!(:support_auditor) do
    user = User.create(email: "support@example.com", password: "password123", role: :auditor)
    puts user.errors.full_messages if user.errors.any?
    user
  end

  let!(:sme) do
    user = User.create(email: "sme@example.com", password: "password123", role: :auditor)
    puts user.errors.full_messages if user.errors.any?
    user
  end

  # Print the total user count to confirm setup and signs in a test user
  before do
    puts "Users created: #{User.count}"
    # @user = User.create(email: "tester@tester.com", password: "test_password", role: :qa_manager)
    sign_in lead_auditor
  end

  # --- NEW ACTION TEST ---
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  # --- CREATE ACTION TESTS ---
  describe "POST #create" do
    # Valid params for a complete audit creation
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
        audit_standard: {
          standard: ["ISO 9001"]
        },
        commit: "Save Changes"
      }
    end



    it "redirects if 'Close Audit' is clicked" do
      post :create, params: valid_params.merge(commit: "Close Audit")
      expect(response).to redirect_to(create_edit_audits_path)
      expect(flash[:notice]).to eq("Audit creation cancelled. No data was saved.")
    end

    it "does not save with missing required fields" do
      post :create, params: valid_params.deep_merge(company: { id: nil })
      expect(response).to render_template(:new)
      expect(flash.now[:alert]).to eq("Please fill in the following required fields: ")
    end

    it "creates audit and associated records successfully" do
      expect {
        post :create, params: valid_params
      }.to change(Audit, :count).by(1)
       .and change(AuditAssignment, :count).by(4) # lead, auditee, support, SME
       .and change(AuditStandard, :count).by(1)
      expect(response).to redirect_to(edit_create_edit_audit_path(Audit.last))
    end

    it "does not raise error if support auditor or SME are blank" do
      params = valid_params.deep_merge(
        audit_assignment: {
          auditee: auditee.id,
          lead_auditor: lead_auditor.id,
          support_auditor: [""], # Blank values
          sme: [""]
        }
      )
      expect {
        post :create, params: params
      }.to change(Audit, :count).by(1)
    end

    it "handles unexpected param structures gracefully" do
      expect {
        post :create, params: valid_params.deep_merge(audit_assignment: nil)
      }.to change(Audit, :count).by(0) # Ensure no new record is created

      # Expect the response to indicate failure due to missing fields
      expect(response).to have_http_status(:success)
      expect(flash[:alert]).to include("Please fill in the following required fields")
    end
  end

  # --- EDIT ACTION TEST ---
  describe "GET #edit" do
    let!(:audit) do
      Audit.create(
        company_id: company.id,
        audit_type: "internal",
        scheduled_start_date: Date.today,
        scheduled_end_date: Date.today + 1
      )
    end

    let!(:audit_detail) do
      AuditDetail.create(
        audit_id: audit.id,
        scope: "Scope",
        objectives: "Obj",
        purpose: "Purp",
        boundaries: "Bound"
      )
    end

    it "renders the edit page with populated data" do
      get :edit, params: { id: audit.id }
      expect(response).to render_template(:edit)
      expect(assigns(:audit)).to eq(audit)
      expect(assigns(:scope)).to eq("Scope")
    end
  end

  # --- UPDATE ACTION TESTS ---
  describe "PATCH #update" do
    let!(:audit) do
      Audit.create(
        company_id: company.id,
        audit_type: "internal",
        scheduled_start_date: Date.today,
        scheduled_end_date: Date.today + 1
      )
    end

    let!(:audit_detail) do
      AuditDetail.create(
        audit_id: audit.id,
        scope: "Scope",
        objectives: "Obj",
        purpose: "Purp",
        boundaries: "Bound"
      )
    end

    it "redirects if 'Close Audit' is clicked" do
      patch :update, params: { id: audit.id, commit: "Close Audit" }
      expect(response).to redirect_to(create_edit_audits_path)
    end

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
      expect(flash.now[:alert]).to match("Please fill in the following required fields: ")
    end

    it "successfully updates audit with valid data" do
      patch :update, params: {
        id: audit.id,
        company: { id: company.id },
        audit_assignment: {
          auditee: auditee.id,
          lead_auditor: lead_auditor.id,
          support_auditor: [support_auditor.id],
          sme: [sme.id]
        },
        audit: {
          audit_type: "external",
          scheduled_start_date: Date.today.to_s,
          scheduled_end_date: (Date.today + 2).to_s,
          actual_start_date: Date.today.to_s,
          actual_end_date: (Date.today + 1).to_s
        },
        audit_detail: {
          scope: "Scope",
          objectives: "Updated Objective",
          purpose: "Updated Purpose",
          boundaries: "Updated Boundaries"
        },
        audit_standard: { standard: ["GMP"] },
        commit: "Save Changes"
      }

      expect(response).to redirect_to(edit_create_edit_audit_path(audit.reload))
      expect(flash[:notice]).to eq("Audit updated successfully.")
      expect(audit.audit_type).to eq("external")
      expect(audit.audit_detail.objectives).to eq("Updated Objective")
    end
  end
end
