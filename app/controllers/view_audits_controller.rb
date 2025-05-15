class ViewAuditsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_audit, only: [:show]

  def show
    Rails.logger.warn "🎯 SHOW ACTION HIT!"
    @assignments = @audit.audit_assignments.includes(:user)
    @schedules = @audit.audit_schedules.includes(:user).order(:created_at)
    @request_letter = @audit.audit_request_letter
    @closure_letter = @audit.audit_closure_letter
    @report = @audit.report
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
  
    is_assigned_user = AuditAssignment.exists?(
      audit_id: @audit.id,
      user_id: current_user.id
    )
  
    is_assigner = AuditAssignment.exists?(
      audit_id: @audit.id,
      assigned_by: current_user.id
    )
  
    Rails.logger.warn "Current user ID: #{current_user.id}, role: #{current_user.role}"
    Rails.logger.warn "is_assigner: #{is_assigner}, is_assigned_user: #{is_assigned_user}, is_auditee_and_related: #{is_auditee_and_related}"

    authorized = is_auditee_and_related || is_assigned_user || is_assigner

    Rails.logger.warn "🔐 Access check: authorized = #{authorized}"

    unless authorized
      Rails.logger.warn "❌ Access denied. Redirecting..."
      redirect_to root_path, alert: "You are not authorized to view this audit."
    end

  end
  
end
