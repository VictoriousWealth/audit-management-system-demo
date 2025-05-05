require 'rails_helper'

RSpec.describe CreateEditAuditsController, type: :controller do
  let!(:company) {
    Company.create(
      name: "company",
      city: "Sheffield",
      postcode: "S1 2FF",
      street_name: "89 London Rd"
    )
  }

  let!(:senior_manager) { 
    User.create(
      email: 'senior.manager@test.com',
      password: 'password123',
      first_name: 'senior',
      last_name: 'manager',
      role: :senior_manager
    ) 
  }

  let!(:qa_manager) { 
    User.create(
      email: 'qa.manager@test.com',
      password: 'password123',
      first_name: 'qa',
      last_name: 'manager',
      role: :qa_manager
    ) 
  }

  let!(:lead_auditor) { 
    User.create(
      email: 'lead.auditor@test.com',
      password: 'password123',
      first_name: 'lead',
      last_name: 'auditor',
      role: :auditor
    ) 
  }

  let!(:support_auditor_1) { 
    User.create(
      email: 'support.auditor1@test.com',
      password: 'password123',
      first_name: 'support',
      last_name: 'auditor1',
      role: :auditor
    ) 
  }

  let!(:support_auditor_2) { 
    User.create(
      email: 'support.auditor2@test.com',
      password: 'password123',
      first_name: 'support',
      last_name: 'auditor2',
      role: :auditor
    ) 
  }

  let!(:auditee_1) { 
    User.create(
      email: 'auditee.1@test.com',
      password: 'password123',
      first_name: 'auditee',
      last_name: '1',
      role: :auditee,
      company_id: company.id
    ) 
  }

  let!(:auditee_2) { 
    User.create(
      email: 'auditee.2@test.com',
      password: 'password123',
      first_name: 'auditee',
      last_name: '2',
      role: :auditee
    ) 
  }

  let!(:sme_1) { 
    User.create(
      email: 'sme.1@test.com',
      password: 'password123',
      first_name: 'sme',
      last_name: '1',
      role: :sme
    ) 
  }

  let!(:sme_2) { 
    User.create(
      email: 'sme.2@test.com',
      password: 'password123',
      first_name: 'sme',
      last_name: '2',
      role: :sme
    ) 
  }

  # Use let to set the user dynamically for each test case
  let(:user) { nil }

  before do
    sign_in user if user
  end
  
  describe "GET #new" do
    context "when signed in as senior manager" do
      let(:user) { senior_manager }

      it "renders the new audit form" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in as qa manager" do
      let(:user) { qa_manager }

      it "renders the new audit form" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in as lead auditor" do
      let(:user) { lead_auditor }

      it "renders the new audit form" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in as auditee" do
      let(:user) { auditee_1 }

      it "does not render the new audit form" do
        get :new
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when signed in as sme" do
      let(:user) { sme_1 }

      it "does not render the new audit form" do
        get :new
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #create" do
    it "creates something" do
      post :create, params: { model: { field: "value" } }
      expect(response).to redirect_to(some_path)
    end
  end
end
