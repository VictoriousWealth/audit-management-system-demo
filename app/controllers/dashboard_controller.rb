# This controller is responsible for routing users to the correct dashboard.
#
# It acts as a landing page after login, redirecting each user
# to a dashboard based on their role in the system.
#
# Inherits from `ApplicationController`.
#
# Before actions:
# - authenticate_user!: ensures that only authenticated users can access the actions in this controller.
class DashboardController < ApplicationController
  before_action :authenticate_user!

  # Redirects the current user to their role-specific dashboard.
  #
  # This action determines the dashboard to show based on the current user's role.
  # It's  used as a landing page after login or when accessing the root/dashboard controller.
  #
  # @return [void] this method performs a redirect and does not render a view
  def index
    case current_user.role
    when 'auditor'
      redirect_to auditor_dashboard_path
    when 'auditee'
      redirect_to auditee_dashboard_path
    when 'qa_manager'
      redirect_to qa_manager_dashboard_path
    when 'senior_manager'
      redirect_to senior_manager_dashboard_path
    when 'sme'
      redirect_to sme_dashboard_path
    else
      redirect_to root_path
    end
  end

end
