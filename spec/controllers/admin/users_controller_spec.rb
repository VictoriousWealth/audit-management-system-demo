require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:qa_manager) { create(:user, :qa_manager) }
  let(:auditor) { create(:user, :auditor) }


  describe "GET #new" do
    context "when user is not signed in" do
      it "redirects to login page" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in but not a QA manager" do
      before { sign_in auditor }

      it "redirects to root with alert" do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end

    context "when QA manager is signed in" do
      before { sign_in qa_manager }

      it "renders the new template" do
        get :new
        expect(response).to render_template(:new)
      end

      it "assigns a new User instance" do
        get :new
        expect(assigns(:user)).to be_a_new(User)
      end

      it "assigns non-nil company names" do
        create(:company, name: "Tesco")
        get :new
        expect(assigns(:companies)).to include("Tesco")
      end
    end
  end

  describe "POST #create" do
    let(:valid_user_params) do
      {
        first_name: "John",
        last_name: "Doe",
        email: "john@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: "auditee"
      }
    end

    let(:company_params) do
      {
        company: "Lidl",
        address_street: "12 The St",
        address_city: "Gotham",
        address_postcode: "S2 5KH"
      }
    end

    context "when not signed in" do
      it "redirects to login" do
        post :create, params: { user: valid_user_params }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in but not QA manager" do
      before { sign_in auditor }

      it "redirects to root with alert" do
        post :create, params: { user: valid_user_params }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end

    context "when signed in as QA manager" do
      before { sign_in qa_manager }

      context "with valid params and new company" do
        it "creates a new user" do
          expect {
            post :create, params: { user: valid_user_params.merge(company_params) }
          }.to change(User, :count).by(1)
        end

        it "creates a new company if it doesn't exist" do
          expect {
            post :create, params: { user: valid_user_params.merge(company_params) }
          }.to change(Company, :count).by(1)
        end

        it "sends a welcome email" do
          allow(UserMailer).to receive_message_chain(:welcome_email, :deliver_now)
          post :create, params: { user: valid_user_params.merge(company_params) }
          expect(UserMailer).to have_received(:welcome_email)
        end

        it "redirects to the admin users path with success message" do
          post :create, params: { user: valid_user_params.merge(company_params) }
          expect(response).to redirect_to(admin_users_path)
          expect(flash[:notice]).to eq("User created successfully.")
        end
      end

      context "with invalid params" do
        it "does not create a user and re-renders new" do
          expect {
            post :create, params: { user: valid_user_params.merge(email: "") }
          }.not_to change(User, :count)

          expect(response).to render_template(:new)
          expect(flash[:alert]).to include("User could not be created")
        end
      end
    end
  end
end
