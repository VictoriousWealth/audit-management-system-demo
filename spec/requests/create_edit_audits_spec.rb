require 'rails_helper'

RSpec.describe "CreateEditAudits", type: :request do
  let!(:company) {
    Company.create!(
      name: "company",
      city: "Sheffield",
      postcode: "S1 2FF",
      street_name: "89 London Rd"
    )
  }

  let!(:qa_manager) {
    User.create!(
      email: 'qa.manager@test.com',
      password: 'password123',
      first_name: 'qa',
      last_name: 'manager',
      role: :qa_manager
    )
  }

  before do
    sign_in qa_manager
  end

  describe "GET /create_edit_audits/new" do
    it "returns success" do
      get new_create_edit_audit_path
      expect(response).to have_http_status(:success)
    end
  end
end
