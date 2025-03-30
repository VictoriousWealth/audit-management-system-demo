class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authorise_qa_manager, only: [:new, :create]
  skip_before_action :require_no_authentication, only: [:new, :create]

  # Allow QA Managers to access the sign-up page
  def new
    build_resource({})
    yield resource if block_given?
    respond_with resource
  end

  # Create the new user account
  def create
    super do |resource|
      resource.role = 'employee' # Ensure new accounts are employees
      resource.save
    end
  end

  private

  # Only QA Managers can create new users
  def authorize_qa_manager
    unless user_signed_in? && current_user.qa_manager?
      flash[:alert] = "You are not authorized to create new users."
      redirect_to root_path
    end
  end
end
