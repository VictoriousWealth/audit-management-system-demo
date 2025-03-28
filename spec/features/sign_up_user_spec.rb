require 'rails_helper'

RSpec.feature "Making a user", type: :feature do

  let(:user2) { create(:user2) }


  scenario "Create a user" do
    # Sign in
    login_as(user2, scope: :user)
    visit root_path

    # Check the link is there
    expect(page).to have_link('Add New User', href: new_admin_user_path)
    # Click the link to go to the page
    click_link "Add New User"
    expect(page).to have_content("Create a user")
    # Fill in the form with valid data
    fill_in "First Name", with: "John"
    fill_in "Last Name", with: "Doe"
    fill_in "Email", with: "johndoe@example.com"
    fill_in "Password", with: "password"
    fill_in "Confirm Password", with: "password"
    expect(page).to have_selector("#role_select", visible: true)
    select "Auditor", from: "user[role]"

    # Get the initial amount of users
    initial_count = User.count
    # Clear the deliveries array before emails are sent
    ActionMailer::Base.deliveries.clear

    # Click the submit button
    click_button "Create User"

    # Check that the user was created
    expect(User.count).to eq(initial_count + 1)
    # Check for the success message
    expect(page).to have_content("User created successfully.")
    # Check that the emails were sent
    expect(ActionMailer::Base.deliveries.count).to eq(2)

    # Check the email content
    email = ActionMailer::Base.deliveries.last
    expect(email.to).to eq(["johndoe@example.com"])
    expect(email.subject).to include("GTIMC Account Creation")
    expect(email.body.encoded).to include("Welcome to the GTIMC, John!")
  end

  # scenario "Create an auditee", js: true do
  #   #Sign in
  #   login_as(user2, scope: :user)
  #   visit root_path
  #   # Chdeck the link is there
  #   expect(page).to have_link('Add New User', href: new_admin_user_path)
  #   # Click the link to go to the page
  #   click_link "Add New User"

  #   expect(page).to have_content("Create a user")
  #   # Fill in the form with valid data
  #   fill_in "First Name", with: "John"
  #   fill_in "Last Name", with: "Doe"
  #   fill_in "Email", with: "johndoe@example.com"
  #   fill_in "Password", with: "password"
  #   fill_in "Confirm Password", with: "password"
  #   # Select Auditee role
  #   select "Auditee", from: "user[role]"
  #   find("select[name='user[role]']").trigger("change")

  #   #Expect the company field to now be visible
  #   expect(page).to have_selector("#company_field", text: "Company")
  # end

  scenario "Create a non auditee" do
    #Sign in
    login_as(user2, scope: :user)
    visit root_path
    # Chdeck the link is there
    expect(page).to have_link('Add New User', href: new_admin_user_path)
    # Click the link to go to the page
    click_link "Add New User"

    expect(page).to have_content("Create a user")
    # Fill in the form with valid data
    fill_in "First Name", with: "John"
    fill_in "Last Name", with: "Doe"
    fill_in "Email", with: "johndoe@example.com"
    fill_in "Password", with: "password"
    fill_in "Confirm Password", with: "password"
    # Select Auditee role
    select "Auditor", from: "user[role]"

    #Expect the company field to now be possible
    expect(page).to_not have_selector("#company_field", text: "Company")

  end


  scenario "User tries to create an account with an existing email" do

    #Sign in
    login_as(user2, scope: :user)
    visit root_path
    # Chdeck the link is there
    expect(page).to have_link('Add New User', href: new_admin_user_path)
    # Click the link to go to the page
    click_link "Add New User"
    expect(page).to have_content("Create a user")

    # Create a user with an email
    existing_user = create(:user, email: "johndoe@example.com")

    # Make a uuser with the same email
    visit new_admin_user_path
    fill_in "First Name", with: "Jane"
    fill_in "Last Name", with: "Doe"
    fill_in "Email", with: "johndoe@example.com"
    fill_in "Password", with: "password"
    fill_in "Confirm Password", with: "password"
    click_button "Create User"

    # Expect an error message
    expect(page).to have_content("Email has already been taken")
  end


end
