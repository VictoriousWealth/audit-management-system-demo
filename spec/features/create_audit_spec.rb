# This line includes the Rails test helper, which sets up the test environment
require "rails_helper"

# Describe a feature spec for creating an audit
RSpec.describe "Creating an audit", type: :feature do
  include Devise::Test::IntegrationHelpers
  # Print the total user count to confirm setup and signs in a test user
  before do
    puts "Users created: #{User.count}"
    @user = User.create(email: "tester@tester.com", password: "test_password", role: :qa_manager)
    sign_in @user
  end

  # Define a scenario that checks for validation errors when submitting an empty form
  it "shows validation error if required fields are blank" do
    # Visit the form page for creating a new audit
    visit new_create_edit_audit_path
  
    # Check if we are on the correct page
    expect(page).to have_current_path(new_create_edit_audit_path)
  
    # Simulate clicking the "Submit" button without filling in the form
    click_button "Submit"
  
    # Expect the page to show a validation message indicating required fields are missing
    expect(page).to have_content("Please fill in the following required fields:")
  end  
end
