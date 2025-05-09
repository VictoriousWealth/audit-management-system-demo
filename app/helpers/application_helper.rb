#Helper methods for the app
module ApplicationHelper

  # Returns the right dashboard path for the given user based on their role.
  #
  # @param user [User] the user who's role is used to determine the dashboard path
  # @return [String] the URL path to the correct dashboard for the user
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
    when 'sme'
      sme_dashboard_path
    else
      root_path
    end
  end

  def markdown(text)
    Kramdown::Document.new(text).to_html
  end

  def cell_color(risk, value, max_value)
    base_colors = {
      "Low Risk" => [120, 60],    # Green
      "Medium Risk" => [39, 100],  # Orange
      "High Risk" => [0, 100]      # Red
    }

    hue, saturation = base_colors[risk]
    base_lightness = 75 # was 90 before — makes initial green less bright
    lightness_range = 45

    lightness = base_lightness - ((value.to_f / max_value) * lightness_range).clamp(0, lightness_range)
    "hsl(#{hue}, #{saturation}%, #{lightness.round}%)"
  end

  def in_company_mode?
    controller_name == 'company_mode' && action_name == 'company_mode'
  end

end
