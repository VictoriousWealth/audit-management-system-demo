class ReportsController < ApplicationController
  before_action :set_audit, :set_audit_detail, only: [:new, :create]
  before_action :set_audit_detail, only: [:new, :create]
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
    @report = Report.find_or_initialize_by(audit: @audit)
    @today_date = Date.today.strftime("%d/%m/%Y")
    @report.user = current_user
  end

  # GET /audit/audit_id/report/show
  def show
  end

  private
    def set_audit
      raise "Missing audit_id parameter" unless params[:audit_id].present?
      @audit = Audit.includes(:audit_detail, :company, :audit_assignments).find(params[:audit_id])
      @start_date = @audit.actual_start_date&.strftime("%d/%m/%Y") ||
      @audit.scheduled_start_date&.strftime("%d/%m/%Y") ||
      "N/A"

      @company = @audit.company
      @company_name = @audit.company&.name
      @location = @company&.street_name + ", " +
      @company&.city + ", " +
      @company&.postcode

    end

    def set_audit_detail
      @audit_scope = @audit.audit_detail.scope
    end

    def set_assignments
      # Get the auditee
      @auditee = audit.audit_assignments.find_by(role: :auditee)&.user 
      @contact = @company&.contact.find_by(last_name: @auditee.last_name)


      # Creates an array of all auditors
      @assigned_auditors = audit.audit_assignments.where(role: :auditor).map(&:user) 
      # Get the lead auditor
      @lead_auditor = audit.audit_assignments.find_by(role: :lead_auditor)&.user 

      # Get the SMEs
      @sme = @audit.audit_assignments.where(role: "sme").map(&:user)
    end

end
