
# Admin controller for making new users.
#
# This controller allows the creation of new users and assigns them to a company.
# It requires the current user to be authenticated and have the 'qa_manager' role.
#
# Before actions:
# - authenticate_user!: ensures that only authenticated users can access the actions in this controller.
# - authorise_qa_manager: ensures that only users with the 'qa_manager' role can access the actions in this controller.
class Admin::UsersController < ApplicationController

  #The user must be authorised and a QA manager to access this page
  before_action :authenticate_user!
  before_action :authorise_qa_manager

  # Renders the form for creating a new user.
  #
  # This action initialises a new user object and retrieves a list of company names that aren't nil
  # to populate the company selection field in the form.
  #
  # @return [void] renders the `new` view for creating a new user.
  def new
    @user = User.new
    @companies = Company.where.not(name: nil).pluck(:name)
  end

  # Creates a new user with the provided parameters.
  #
  # This action extracts custom fields like the company details from the form input.
  # It either finds an existing company or creates a new company if one does not already exist.
  # After creating the user, a welcome email is sent, and the user is redirected to the user list page.
  #
  # @return [void] redirects to the `admin_users_path` with a success message if the user is created successfully,
  # or renders the `new` view with an error message if the user creation fails.
  def create
    # Extract custom fields before permitting params
    company_name = params[:user].delete(:company)
    street_name  = params[:user].delete(:address_street)
    city         = params[:user].delete(:address_city)
    postcode     = params[:user].delete(:address_postcode)

    # Gets the company name and find its id (creates one if it's not there)
    if company_name.present?
      # Check if the company already exists
      company = Company.find_or_create_by(name: company_name.strip) do |c|
        c.street_name = street_name
        c.city        = city
        c.postcode    = postcode
      end
      company.save
      #Create a new user
      @user = User.new(user_params)
      @user.company_id = company.id if company.present?
    else 
      @user = User.new(user_params)
    end


    if @user.save
      # Send the welcome email after user is made
      UserMailer.welcome_email(@user).deliver_now
      redirect_to admin_users_path, notice: 'User created successfully.'
    else
      #If the user is not saved, alert the user
      Rails.logger.error "User creation failed: #{@user.errors.full_messages.join(', ')}"
      flash.now[:alert] = "User could not be created: #{@user.errors.full_messages.join(', ')}"
      @companies = Company.where.not(name: nil).pluck(:name) # reload for the view
      render :new
    end
  end

  private

  # Parameters for user creation.
  #
  # Specifies the required parameters for creating a new user.
  #
  # @return [ActionController::Parameters] the permitted parameters for creating a user.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role, :company_id)
  end

  # Ensures that only users with the 'qa_manager' role can access the actions in this controller.
  #
  # If the current user does not have the 'qa_manager' role, they will be redirected
  # to the root path with an alert message.
  #
  # @return [void] redirects to the root path with an alert message if the user is not authorised.
  def authorise_qa_manager
    redirect_to root_path, alert: 'Access denied' unless current_user.role == 'qa_manager'
  end
end
