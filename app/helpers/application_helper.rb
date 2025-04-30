module ApplicationHelper
  #Helps you find the correct dashboard for each user
  def dashboard_path_for(user)
    helpers = Rails.application.routes.url_helpers

    case user.role
    when 'auditee'
      auditee_dashboard_path
    when 'qa_manager'
      qa_manager_dashboard_path
    when 'senior_manager'
      senior_manager_dashboard_path
    when 'auditor'
      auditor_dashboard_path
    else
      root_path
    end
  end

  def markdown(text)
    Kramdown::Document.new(text).to_html
  end
end
