class AuditRequestLettersController < ApplicationController
  before_action :set_audit, only: [:new, :create, :edit, :update]
  before_action :set_audit_detail, only: [:new, :view]

  # GET /audit/audit_id/create-audit-request-letter
  def new
    @audit_request_letter = AuditRequestLetter.new(audit: @audit, user: current_user)
    @today_date = Date.today.strftime("%d/%m/%Y")
    audit_assignments = @audit.audit_assignments.includes(:user)
  
    # Get the company
    @company = @audit.company

    # Get the auditee
    @auditee = audit_assignments.find_by(role: :auditee)&.user 

    # Creates an array of all auditors
    @assigned_auditors = audit_assignments.where(role: :auditor).map(&:user) 
    # Get the lead auditor
    @lead_auditor = audit_assignments.find_by(role: :lead_auditor)&.user 
  end

  def create
    @audit_request_letter = @audit.build_audit_request_letters(audit_request_letter_params)
    @audit_request_letter.user = current_user
    @audit_request_letter.time_of_creation = Time.current

    if @audit_request_letter.save
      redirect_to audit_path(@audit), notice: "Audit Request Letter created successfully."
    else
      render :new
    end
  end
  def audit_request_letter_view
      render 'pages/letters/audit-request-letter-view'
  end

  private
    def set_audit
      raise "Missing audit_id in params" unless params[:audit_id].present?
      @audit = Audit.includes(:audit_detail, :company).find(params[:audit_id])
      raise "Audit not found" unless @audit.present?
    end

    def set_audit_detail
      @audit_detail = AuditDetail.find_by(audit: @audit)
    end

    def audit_request_letter_params
      params.require(:audit_request_letter).permit(
        :content,
        :time_of_distribution,
        :time_of_verification
      )
    end
end