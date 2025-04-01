class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorise_qa_manager

  def new
    @user = User.new
    @companies = Company.where.not(name: nil).pluck(:name)

  end

  # def create
  #   @user = User.new(user_params)
  #   if @user.save
  #     redirect_to admin_users_path, notice: 'User created successfully.'
  #   else
  #     render :new
  #   end
  # end

  def create
    # Extract custom fields before permitting params
    company_name = params[:user].delete(:company)
    street_name  = params[:user].delete(:address_street)
    city         = params[:user].delete(:address_city)
    postcode     = params[:user].delete(:address_postcode)
    
    # Gets the company name and finds it id (creates one if not there)
    if company_name.present?
      # Check if the company already exists
      company = Company.find_or_create_by(name: company_name.strip) do |c|
        c.street_name = street_name
        c.city        = city
        c.postcode    = postcode
      end
  
      @user = User.new(user_params)
      @user.company_id = company.id if company.present?
    end
  
    @user = User.new(user_params)
  
    if @user.save
      
      #@user.send_reset_password_instructions
      # Send the welcome email
      UserMailer.welcome_email(@user).deliver_now
      redirect_to admin_users_path, notice: 'User created successfully.'
    else
      Rails.logger.error "User creation failed: #{@user.errors.full_messages.join(', ')}"
      flash.now[:alert] = "User could not be created: #{@user.errors.full_messages.join(', ')}"
      @companies = Company.where.not(name: nil).pluck(:name) # reload for the view
      render :new
    end
  end
  

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role, :company_id)
  end

  def authorise_qa_manager
    redirect_to root_path, alert: 'Access denied' unless current_user.role == 'qa_manager'
  end
end
