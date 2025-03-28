require "rails_helper"

RSpec.describe "Creating an audit", type: :feature do
  it "shows validation error if required fields are blank" do
    visit new_create_edit_audit_path
    click_button "Submit"
    expect(page).to have_content("Please fill in all required fields")
  end
end
