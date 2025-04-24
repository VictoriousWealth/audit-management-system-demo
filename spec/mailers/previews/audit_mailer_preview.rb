# Preview all emails at http://localhost:3000/rails/mailers/audit_mailer_mailer
class AuditMailerPreview < ActionMailer::Preview
  def notify_assignment
    assignment = AuditAssignment.first || AuditAssignment.new(
      user: User.new(email: "test@eNina.com", first_name: "Test", last_name: "User"),
      audit: Audit.new(id: 123),
      role: :lead_auditor
    )
    AuditMailer.notify_assignment(assignment)
  end
end
