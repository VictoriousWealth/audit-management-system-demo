require "rails_helper"

RSpec.describe AuditMailer, type: :mailer do
  describe "notify_assignment" do
    let(:user) { create(:user, email: "test@nina.com", first_name: "Nina") }
    let(:user2) { create(:user2) }

    let(:company) { create(:company) }
    let(:audit) { create(:audit, company: company) }
    let(:assignment) { create(:audit_assignment, user: user, assigned_by: user2.id, audit: audit, role: :lead_auditor) }


    let(:mail) { AuditMailer.notify_assignment(assignment) }

    it "has the correct subject" do
      expect(mail.subject).to eq("You have been assigned to audit ##{audit.id} as  #{assignment.role.to_s.humanize}")
    end

    it "sends the email to the correct address" do
      expect(mail.to).to eq([user.email])
    end

    it "has the correct sender email" do
      expect(mail.from).to eq(["no-reply@GTIMC.com"])
    end

    it "includes the user's first name in the body" do
      expect(mail.body.encoded).to include("Hello #{user.first_name}")
    end

    it "includes the audit ID in the body" do
      expect(mail.body.encoded).to include("audit ##{audit.id}")
    end

    it "mentions the role in the email body" do
      expect(mail.body.encoded).to include("as #{assignment.role.to_s.humanize}")
    end
  end
end
