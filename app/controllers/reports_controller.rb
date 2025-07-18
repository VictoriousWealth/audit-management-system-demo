class ReportsController < ApplicationController
  before_action :set_audit, :set_audit_detail, only: [:new, :create, :show]
  before_action :set_audit_detail, only: [:new, :create, :show]
  before_action :set_assignments, only: [:new, :create, :show]

  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:save_audit_letter] 

  # Check if the user is authorized to perform actions on the audit request letter
  # authorize_resource

  def new
    @audit = Audit.find(params[:audit_id])
    @report = Report.find_or_initialize_by(audit: @audit)
    @pending_findings = session[:audit_findings] || []
  end
  
  def create
    @audit = Audit.find(params[:audit_id])
    @report = Report.find_or_initialize_by(audit: @audit)

    @report.user = current_user
    if @report.save
      (session[:audit_findings] || []).each do |f|
        puts "Creating finding: #{f.inspect}"
        @report.audit_findings.create(f)
      end
      session[:audit_findings] = nil
      redirect_to view_audit_path(@audit), notice: "Report created with findings"
    else
      render :show, notice: "Report not created"
    end
  end

  # GET /audit/audit_id/report/show
  def show
    @report = @audit.report
    @audit_findings = @report.audit_findings
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
      audit_assignments = @audit.audit_assignments.includes(:user)

      # Get the auditee
      @auditee = audit_assignments.find_by(role: :auditee)&.user 
      @contact = @company&.contacts.find_by(company_id: @company.id) || "N/A"


      # Creates an array of all auditors
      @assigned_auditors = audit_assignments.where(role: :auditor).map(&:user) 
      # Get the lead auditor
      @lead_auditor = audit_assignments.find_by(role: :lead_auditor)&.user 

      # Get the SMEs
      @smes = audit_assignments.where(role: "sme").map(&:user)
    end

    def report_params
      params.require(:report).permit(
        :audit_id,
        :user_id,
      )
    end

end
