class AuditClosureLettersController < ApplicationController
  before_action :set_audit, only: [:new, :create, :edit, :update]

  def new
    @audit_closure_letter =  AuditClosureLetter.new(audit: @audit, user: current_user)
    @company = @audit.company

    audit_assignments = @audit.audit_assignments.includes(:user)

    @auditee = audit_assignments.find_by(role: :auditee)&.user 
    @lead_auditor = audit_assignments.find_by(role: :lead_auditor)&.user 
    @assigned_auditors = audit_assignments.where(role: :auditor).map(&:user) 

    @findings = AuditFinding.joins(:report).where(reports: {audit_id: @audit.id}).includes(report: :user)

    @corrective_actions = @audit.corrective_actions
  end

  def create
    @audit = Audit.find(params[:audit_id])
    @audit_closure_letter = @audit.build_audit_closure_letters(audit_closure_letter_params)
    @audit_closure_letter.user = current_user
    @audit_closure_letter.time_of_creation = Time.current

    if @audit_closure_letter.save
      redirect_to audit_path(@audit), notice: "Audit Closure Letter created successfully."
    else
      render :new
    end
  end

  private

  def set_audit
    @audit = Audit.includes(
      :company, {reports: :audit_findings}, :corrective_actions
    ).find(params[:audit_id])
  end
  

  def audit_closure_letter_params
    params.require(:audit_closure_letter).permit(
      :content,
      :time_of_distribution,
      :time_of_verification
    )
  end
end