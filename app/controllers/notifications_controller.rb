# This controller is responsible for managing user notifications related to audit assignments.
#
# It handles displaying audit assignments that need acknowledgment as well as those
# previously assigned by the current user.
#
# Inherits from `ApplicationController`.
#
# Before actions:
# - authenticate_user!: ensures that only authenticated users can access the actions in this controller.
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # Displays audit assignments relevant to the current user.
  #
  # - Lists unacknowledged assignments assigned to the current user (those not accepted).
  # - Lists acknowledged assignments that were assigned by the current user.
  #
  # @return [void] renders the default view with assignment instance variables
  def index
    #Find the current user's unacknowledged assignements and sort them
    @audit_assignments = AuditAssignment.all
    @unacknowledged_assignments = @audit_assignments
      .where(time_accepted: nil)
      .where(user_id: current_user.id)
      .order(created_at: :desc)

    #Find the current user's recieved acknowledged assignements and sort them
    @acknowledged_assignments = @audit_assignments
      .where.not(time_accepted: nil)
      .where(assigned_by: current_user.id)
      .order(time_accepted: :desc)
  end

  # Acknowledges an audit assignment for the current user.
  #
  # Finds the audit assignment by ID and, if it belongs to the current user,
  # marks it as acknowledged by setting the `time_accepted` field.
  #
  # @return [void] redirects the user back or to the notifications page
  def accept
    assignment = AuditAssignment.find(params[:id])
    if assignment.user_id == current_user.id
      #Acknowledged assignemnts have a time of acceptance (way to differentiate)
      assignment.update(time_accepted: Time.current)
    end
    redirect_back fallback_location: notifications_path
  end

end
