class ViewAuditsController < ApplicationController
  before_action :set_audit, only: [:show]

  def show
    @assignments = @audit.audit_assignments.includes(:user)
    @schedule = @audit.audit_schedules.order(:created_at)
    @request_letter = @audit.audit_request_letters.order(created_at: :desc).first
    @closure_letter = @audit.audit_closure_letters.order(created_at: :desc).first
    @report = @audit.reports.order(created_at: :desc).first
    @supporting_documents = @audit.supporting_documents.order(created_at: :desc)
  end

  private

  def set_audit
    @audit = Audit.find(params[:id])
  end
end
