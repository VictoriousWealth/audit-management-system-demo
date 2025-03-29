class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Disabling caching will prevent sensitive information being stored in the
  # browser cache. If your app does not deal with sensitive information then it
  # may be worth enabling caching for performance.
  before_action :update_headers_to_disable_caching

  # The user goes to the dashboard after logging in
  def after_sign_in_path_for(resource)
    case resource.role
    when 'auditor'
      auditor_dashboard_path
    when 'auditee'
      auditee_dashboard_path
    when 'qa_manager'
      qa_manager_dashboard_path
    when 'senior_manager'
      senior_manager_dashboard_path
    else
      root_path
    end
  end


  # The user goes to the root path after loggin out
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  #This is so that only the QA manager can access the create user page
  def authorise_qa_manager
    unless current_use.roler == qa_manager
      flash[:alert] = "You are not authorised to perform this action."
      redirect_to root_path
    end
  end

  # Ensure that the user is authenticated before allowing them to access the
  # application. This will redirect the user to the login page if they are not
  # authenticated
  #before_action :authenticate_user!


  private
    def update_headers_to_disable_caching
      response.headers['Cache-Control'] = 'no-cache, no-cache="set-cookie", no-store, private, proxy-revalidate'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = '-1'
    end


end
