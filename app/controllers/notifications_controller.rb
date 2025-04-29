class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @audit_assignments = AuditAssignment.all
    @unacknowledged_assignments = @audit_assignments
      .where(time_accepted: nil)
      .where(user_id: current_user.id)
      .order(created_at: :desc)

    @acknowledged_assignments = @audit_assignments
      .where.not(time_accepted: nil)
      .where(assigned_by: current_user.id)
      .order(time_accepted: :desc)
  end

  #This is for acknowledging your audit assignment
  def accept
    assignment = AuditAssignment.find(params[:id])
    if assignment.user_id == current_user.id
      #Acknowledged assignemnts have a time of acceptance (way to differentiate)
      assignment.update(time_accepted: Time.current)
    end
    redirect_back fallback_location: notifications_path
  end

end
