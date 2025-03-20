class LettersController < ApplicationController
  def audit_request_letter_create
    @today_date = Date.today.strftime("%d/%m/%Y")
    # @audit = audit.getbyid()
    @scope = "This is the scope of the audit which will be filled from the audit once it is implemented"
    @audit_dates = "20/03/2025 - 20/03/2025"
    @audit_location = "This is the location of the audit which will be filled from the audit once it is implemented"
    @audit_criteria = "This is the criteria of the audit which will be filled from the audit once it is implemented"
    @audit_objective = "This is the objective of the audit which will be filled from the audit once it is implemented"
    render 'pages/letters/audit-request-letter-create'
  end
end
