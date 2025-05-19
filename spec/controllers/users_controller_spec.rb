# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "GET #show" do
    let(:auditor) { create(:user, :auditor) }

    before do
      sign_in auditor
      get :show
    end

    it "assigns the current user to @user" do
      expect(assigns(:user)).to eq(auditor)
    end

    it "renders the show template" do
      expect(response).to render_template(:show)
    end

    it "responds with success" do
      expect(response).to have_http_status(:ok)
    end
  end
end
