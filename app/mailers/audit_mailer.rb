# Handles the sending of emails for audit assignments and updates
class AuditMailer < ApplicationMailer

  # Sets the default from address for all mail sent by this mailer
  default from: 'no-reply@GTIMC.com'

  # Sends an email notifying a user that they have been assigned to an audit
  #
  # @param assignment [Assignment] the assignment object containing user, audit, and role information
  # @return [Mail::Message] the email message object
  def notify_assignment(assignment)
    @user = assignment.user
    @audit = assignment.audit
    @role = assignment.role
    #The email subject and recipient
    mail(
      to: @user.email,
      subject: "You have been assigned to audit ##{@audit.id} as  #{@role.to_s.humanize}"
    )
  end

  # Sends an email notifying a user that an audit has been updated
  #
  # @param assignment [Assignment] the assignment object containing user and audit information
  # @return [Mail::Message] the email message object
  def update_audit(assignment)
    @user = assignment.user
    @audit = assignment.audit
    @role = assignment.role
    #The email subject and recipient
    mail(
      to: @user.email,
      subject: "Update to audit ##{@audit.id}"
    )
  end
end
