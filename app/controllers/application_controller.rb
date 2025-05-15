# The base application controller.
#
# This controller provides common functionality shared across the application.
# It includes CSRF protection, caching headers, and role-based redirection logic
# after login/logout. It can also enforce access control for QA managers.
#
# Inherits from `ActionController::Base`.
class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Disabling caching will prevent sensitive information being stored in the
  # browser cache. If your app does not deal with sensitive information then it
  # may be worth enabling caching for performance.
  before_action :update_headers_to_disable_caching

  # Redirects a signed in user to a dashboard based on their role.
  #
  # This method overrides Devise's default redirection after sign in.
  # It inspects the user's role and sends them to the appropriate dashboard.
  #
  # @param user [User] the user who has just signed in
  # @return [String] the path to the user's dashboard based on their role
  def after_sign_in_path_for(user)
    case user.role
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

  # Determines the redirect path after a user signs out.
  #
  # @param resource [Object] the resource that was signed out (not used)
  #
  # @return [String] the path to redirect to after sign out
  def after_sign_out_path_for(resource)
    root_path
  end

  # Ensures that only users who are QA managers can access certain pages.
  #
  # Redirects unauthorised users to the root path with an alert message.
  #
  # @return [void]
  def authorise_qa_manager
    unless current_user.role == qa_manager
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
