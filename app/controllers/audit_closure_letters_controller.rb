class AuditClosureLettersController < ApplicationController
  before_action :set_audit, only: [:new, :create, :edit, :update]
  before_action :authenticate_user!

  def index
    @audit_closure_letters = AuditClosureLetter.includes(:audit, :user).all
  end

  def show
    @audit_closure_letter = AuditClosureLetter.find(params[:id])
    @audit = @audit_closure_letter.audit
    @company = @audit.company
    @content = JSON.parse(@audit_closure_letter.content || "{}")
  
    audit_assignments = @audit.audit_assignments.includes(:user)
    @auditee = audit_assignments.find_by(role: :auditee)&.user
    @lead_auditor = audit_assignments.find_by(role: :lead_auditor)&.user
    @assigned_auditors = audit_assignments.where(role: :auditor).map(&:user)
  
    @findings = AuditFinding.joins(:report).where(reports: {audit_id: @audit.id}).includes(report: :user)
    @corrective_actions = @audit.corrective_actions
  end
  
  def new
    @audit_closure_letter =  AuditClosureLetter.new(audit: @audit, user: current_user)
    @company = @audit.company

    audit_assignments = @audit.audit_assignments.includes(:user)

    @auditee = audit_assignments.find_by(role: :auditee)&.user 
    @lead_auditor = audit_assignments.find_by(role: :lead_auditor)&.user 
    @assigned_auditors = audit_assignments.where(role: :auditor).map(&:user) 

    @findings = AuditFinding.joins(:report).where(reports: {audit_id: @audit.id}).includes(report: :user)

    @corrective_actions = @audit.corrective_actions # CAPAs yeahhhhh!!!!
  end

  def create
    @audit = Audit.find(params[:audit_id])
    @company = @audit.company
  
    audit_assignments = @audit.audit_assignments.includes(:user)
    @auditee = audit_assignments.find_by(role: :auditee)&.user
    @lead_auditor = audit_assignments.find_by(role: :lead_auditor)&.user
    @assigned_auditors = audit_assignments.where(role: :auditor).map(&:user)
    @findings = AuditFinding.joins(:report).where(reports: {audit_id: @audit.id}).includes(report: :user)
    @corrective_actions = @audit.corrective_actions
  
    @audit_closure_letter = @audit.build_audit_closure_letter(audit_closure_letter_params)
    @audit_closure_letter.user = current_user
    @audit_closure_letter.time_of_creation = Time.current

    # set the structured content as JSON
    @audit_closure_letter.content = {
      company: {
        name: @company.name,
        city: @company.city,
        postcode: @company.postcode,
        street_name: @company.street_name
      },
      audit: {
        id: @audit.id,
        reference: @audit.id.to_s.rjust(6, "0"),
        start_date: @audit.actual_start_date&.strftime("%Y-%m-%d"),
        end_date: @audit.actual_end_date&.strftime("%Y-%m-%d"),
        scope: @audit.audit_detail&.scope
      },
      notes: {
        overall_compliance: params[:audit_closure_letter][:overall_compliance],
        summary_statement: params[:audit_closure_letter][:summary_statement],
        auditee_acknowledged: params[:audit_closure_letter][:auditee_acknowledged].to_s == "1",
        auditor_acknowledged: params[:audit_closure_letter][:auditor_acknowledged].to_s == "1"
      }
    }.to_json
  
    if @audit_closure_letter.save
      redirect_to audit_closure_letters_path, notice: "Audit Closure Letter created successfully."
    else
      render :new
    end
  end

  def destroy
    @audit = Audit.find(params[:audit_id])
    @audit_closure_letter = @audit.audit_closure_letter
  
    if @audit_closure_letter.destroy
      redirect_to audit_closure_letters_path(@audit), notice: "Audit Closure Letter deleted successfully."
    else
      redirect_to audit_closure_letters_path(@audit), alert: "Failed to delete the closure letter."
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
      :time_of_distribution,
      :time_of_verification,
      :summary_statement,       
      :overall_compliance,
      :auditee_acknowledged,
      :auditor_acknowledged       
    )
  end
end