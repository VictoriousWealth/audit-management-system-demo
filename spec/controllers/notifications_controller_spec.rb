require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do

  let(:qa_manager) { create(:user, :qa_manager) }
  let(:auditor) { create(:user, :auditor) }
  let(:company) { create(:company)}
  let(:audit) { create(:audit, user: auditor, company_id: company.id) }
  let!(:unacknowledged_assignment) {create(:audit_assignment, user: auditor, assigned_by: qa_manager.id, audit: audit, role: :lead_auditor, status: :assigned, time_accepted: nil)}
  let!(:acknowledged_assignment) {create(:audit_assignment, user: auditor, assigned_by: qa_manager.id, audit: audit, role: :lead_auditor, status: :assigned, time_accepted: 1.day.ago)}

  describe "GET #index" do
    it "assigns unacknowledged assignments for the current user" do
      sign_in auditor
      get :index
      expect(assigns(:unacknowledged_assignments)).to include(unacknowledged_assignment)
      expect(assigns(:unacknowledged_assignments)).not_to include(acknowledged_assignment)
    end

    it "assigns acknowledged assignments assigned by the current user" do
      sign_in qa_manager
      get :index
      expect(assigns(:acknowledged_assignments)).to include(acknowledged_assignment)
      expect(assigns(:acknowledged_assignments)).not_to include(unacknowledged_assignment)
    end
  end

  describe "POST #accept" do
    it "updates the time_accepted and redirects back" do
      sign_in auditor
      request.env["HTTP_REFERER"] = "/previous_page"
      post :accept, params: { id: unacknowledged_assignment.id }
      expect(unacknowledged_assignment.reload.time_accepted).not_to be_nil
      expect(response).to redirect_to("/previous_page")
    end
  end
end
