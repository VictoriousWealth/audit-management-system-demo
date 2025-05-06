require 'rails_helper'

RSpec.describe CreateEditAuditsController, type: :controller do
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

  shared_examples "can access edit and update" do |user_symbol|
    it "#{user_symbol} can GET #edit" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      get :edit, params: { id: audit.id }
      expect(controller.current_user).to eq(user)
      expect(response).to have_http_status(:ok)
    end
  
    it "#{user_symbol} can PATCH #update (discard)" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      patch :update, params: { id: audit.id, commit: "Discard Edits" }
      expect(response).to have_http_status(:found)
    end
  end
  
  shared_examples "cannot access edit and update" do |user_symbol|
    it "#{user_symbol} is denied GET #edit" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      get :edit, params: { id: audit.id }
      expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
    end
  
    it "#{user_symbol} is denied PATCH #update" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      patch :update, params: { id: audit.id, commit: "Discard Edits" }
      expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
    end
  end
  
  shared_examples "can access new and create" do |user_symbol|
    it "#{user_symbol} can GET #new" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      get :new
      expect(response).to have_http_status(:ok)
    end
  
    it "#{user_symbol} can POST #create (Discard Edits)" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      post :create, params: { commit: "Discard Edits" }
      expect(response).to have_http_status(:found)
    end
  end
  
  shared_examples "cannot access new and create" do |user_symbol|
    it "#{user_symbol} is denied GET #new" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      get :new
      expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
    end
  
    it "#{user_symbol} is denied POST #create" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      post :create, params: {}
      expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
    end
  end

  
  # Allowed roles
  include_examples "can access edit and update", :senior_manager
  include_examples "can access edit and update", :qa_manager
  include_examples "can access edit and update", :lead_auditor
  include_examples "can access edit and update", :support_auditor

  # Not allowed
  include_examples "cannot access edit and update", :unassigned_auditor
  include_examples "cannot access edit and update", :other_qa
  include_examples "cannot access edit and update", :sme
  include_examples "cannot access edit and update", :auditee

  include_examples "can access new and create", :qa_manager
  include_examples "can access new and create", :senior_manager

  include_examples "cannot access new and create", :lead_auditor
  include_examples "cannot access new and create", :support_auditor
  include_examples "cannot access new and create", :sme
  include_examples "cannot access new and create", :auditee

  context "when unauthenticated" do
    it "redirects GET #new to root" do
      get :new
      expect(response).to redirect_to(new_user_session_path)
    end
  
    it "redirects POST #create to root" do
      post :create, params: {}
      expect(response).to redirect_to(new_user_session_path)
    end
  
    it "redirects GET #edit to root" do
      get :edit, params: { id: audit.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  
    it "redirects PATCH #update to root" do
      patch :update, params: { id: audit.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  end  
end
