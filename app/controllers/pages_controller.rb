class PagesController < ApplicationController

  def home
  end

  def audit_request_letter_create
    render 'pages/letters/audit-request-letter-create'
  end

end