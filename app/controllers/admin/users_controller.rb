class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorise_qa_manager

  def new
    @user = User.new
    @companies = Company.pluck(:name) # Gets all company names as an array

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
    # Gets the company name and finds it id (creates one if not there)
    company_name = params[:user].delete(:company)
    company_address = params[:user].delete(:address)

    if company_name.present?
      company = Company.find_or_create_by(name: company_name.strip) do |c|
        c.address = company_address.strip if company_address.present?
        c.created_at = Time.current
      end
      params[:user][:company_id] = company.id
    end

    @user = User.new(user_params)

    if @user.save

      #@user.send_reset_password_instructions
      # Send the welcome email
      UserMailer.welcome_email(@user).deliver_now
      redirect_to admin_users_path, notice: 'User created successfully.'
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role, :company_id, :address)
  end

  def authorise_qa_manager
    redirect_to root_path, alert: 'Access denied' unless current_user.role == 'qa_manager'
  end
end
