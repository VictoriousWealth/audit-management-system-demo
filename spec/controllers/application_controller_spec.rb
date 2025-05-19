require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # Create a dummy controller for testing ApplicationController methods
  controller do
    before_action :update_headers_to_disable_caching
    before_action :authorise_qa_manager, only: [:qa_only_action]

    def index
      render plain: "Index page"
    end

    def qa_only_action
      render plain: "QA only"
    end
  end

  before do
    # Needed so Devise path helpers (and request context) work
    routes.draw do
      get 'qa_only_action' => 'anonymous#qa_only_action'
      get 'index' => 'anonymous#index'
    end
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:qa_manager) { create(:user, :qa_manager) }
  let(:auditor) { create(:user, :auditor) }


  describe '#after_sign_in_path_for' do
    it ' HEY redirects QA manager to their dashboard' do
      user = build_stubbed(:user, role: 'qa_manager')
      routes.draw { get "dummy" => "anonymous#index" }  # simulate routes
      expect(controller.after_sign_in_path_for(user)).to eq qa_manager_dashboard_path
    end

    it 'redirects unknown role to root' do
      result = controller.after_sign_in_path_for(build_stubbed(:user, role: nil))
      expect(result).to eq root_path
    end
  end



  describe '#after_sign_out_path_for' do
    it 'redirects to root path' do
      expect(controller.after_sign_out_path_for(nil)).to eq(root_path)
    end
  end

  describe '#authorise_qa_manager' do
    it 'allows QA manager through' do
      sign_in qa_manager
      get :qa_only_action
      expect(response.body).to include("QA only")
    end

    it 'redirects non-QA user' do
      sign_in auditor
      get :qa_only_action
      #get :new_admin_user
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorised to perform this action.")
    end
  end

  describe 'caching headers' do
    it 'sets no-cache headers' do
      get :index
      expect(response.headers['Cache-Control']).to include('no-store')
      expect(response.headers['Pragma']).to eq('no-cache')
      expect(response.headers['Expires']).to eq('-1')
    end
  end
end
