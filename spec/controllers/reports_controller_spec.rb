require 'rails_helper'

RSpec.describe ReportsController, type: :controller do

  # creating test values 
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:audit) { create(:audit, company: company) }
  let(:audit_detail) { create(:audit_detail, audit: audit) }
  let!(:report) { FactoryBot.create(:report, audit: audit, user: user) }
  
  before do
    sign_in user
  end

  describe "Get #new" do
    it 'returns success and creates a new instance of Report' do
      get :new, params: { audit_id: audit.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:report)).to be_a_new(Report)
    end
  end
end


