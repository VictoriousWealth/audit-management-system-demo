class DashboardController < ApplicationController
  before_action :authenticate_user!

  #Doifferent dashboards for different user types
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

  # this method can be removed
  def auditor
  end

  def auditee
  end

  # this method can be removed
  def qa_manager
  end

  def senior_manager
  end

end
