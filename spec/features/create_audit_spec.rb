# This line includes the Rails test helper, which sets up the test environment
require "rails_helper"

# Describe a feature spec for creating an audit
RSpec.describe "Creating an audit", type: :feature do

  # Define a scenario that checks for validation errors when submitting an empty form
  it "shows validation error if required fields are blank" do
    # Visit the form page for creating a new audit
    visit new_create_edit_audit_path

    # Simulate clicking the "Submit" button without filling in the form
    click_button "Submit"

    # Expect the page to show a validation message indicating required fields are missing
    expect(page).to have_content("Please fill in the following required fields:")
  end
end
