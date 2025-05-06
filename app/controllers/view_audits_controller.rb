class ViewAuditsController < ApplicationController
  before_action :set_audit, only: [:show]

  def show
    @assignments = @audit.audit_assignments.includes(:user)
    @schedules = @audit.audit_schedules.includes(:user).order(:created_at)
    @request_letter = @audit.audit_request_letter
    @closure_letter = @audit.audit_closure_letter
    @report = @audit.reports.order(created_at: :desc).first
    @supporting_documents = @audit.supporting_documents.includes(:user).order(created_at: :desc)
  end

  private

  def set_audit
    @audit = Audit.includes(
      :audit_schedules,
      audit_detail: :audit_standards
    ).find(params[:id])
  
    return if current_user.senior_manager?
  
    is_auditee_and_related = current_user.auditee? && current_user.company_id == @audit.company_id
  
    is_assigned = AuditAssignment.exists?(
      audit_id: @audit.id,
      user_id: current_user.id
    ) || AuditAssignment.exists?(
      audit_id: @audit.id,
      assigned_by: current_user.id
    )
  
    unless is_auditee_and_related || is_assigned
      redirect_to root_path, alert: "You are not authorized to view this audit."
    end
  end  
end
