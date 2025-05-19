require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe "GET #home" do
    it "returns a successful response" do
      get :home
      expect(response).to have_http_status(:ok) # or :success
    end

    it "renders the home template" do
      get :home
      expect(response).to render_template(:home)
    end
  end
end
