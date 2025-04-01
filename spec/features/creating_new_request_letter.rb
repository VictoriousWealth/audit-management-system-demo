require "rails_helper"

describe "Creating a new audit request letter" do
  specify "User can create a new audit request letter" do
    user = User.create(email: 'manager.email.address@sheffield.ac.uk', password: 'Password123', password_confirmation: 'Password123', manager: true)
    login_as user

