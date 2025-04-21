class AuditMailer < ApplicationMailer
  default from: 'no-reply@GTIMC.com'

  def notify_assignment(user, audit)
    @user = user
    @audit = audit
    mail(
      to: @user.email,
      subject: "You have been assigned to Audit ##{@audit.id}"
    )
  end
end
