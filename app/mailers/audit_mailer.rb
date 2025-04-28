class AuditMailer < ApplicationMailer
  default from: 'no-reply@GTIMC.com'

  def notify_assignment(assignment)
    @user = assignment.user
    @audit = assignment.audit
    @role = assignment.role

    mail(
      to: @user.email,
      subject: "You have been assigned to audit ##{@audit.id} as  #{@role.to_s.humanize}"
    )
  end

  def update_audit(assignment)
    @user = assignment.user
    @audit = assignment.audit
    @role = assignment.role

    mail(
      to: @user.email,
      subject: "Update to audit ##{@audit.id}"
    )
  end
end
