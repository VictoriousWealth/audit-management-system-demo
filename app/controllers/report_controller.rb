class ReportController < ApplicationController
  # before_action :set_report, only: [:show, :edit, :update, :destroy]
  # before_action :set_audit, only: [:new, :create, :show]
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:save_audit_letter] 

  # Check if the user is authorized to perform actions on the audit request letter
  # authorize_resource

  def new
    @report = Report.find_or_initialize_by(audit: @audit)
    @today_date = Date.today.strftime("%d/%m/%Y")
  end

    # GET /audit/audit_id/report/new
    def create
    end

  # GET /audit/audit_id/report/show
  def show
  end


end
