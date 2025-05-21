require "rails_helper"

# This spec tests the functionality of the AuditMailer class
# - notify_assignment: Notifies a user about their assignment to an audit
# - update_audit: Notifies a user when there is an update to their assigned audit
#
# The tests verify that each email has the right content
#
RSpec.describe AuditMailer, type: :mailer do

  describe "notify_assignment" do
    let(:auditor) { create(:user, :auditor, email: "auditor@test.com") }
    let(:qa_manager) { create(:user, :qa_manager, email: "qa@test.com") }


    let(:company) { create(:company) }
    let(:audit) { create(:audit, company: company) }
    let(:assignment) { create(:audit_assignment, user: auditor, assigned_by: qa_manager.id, audit: audit, role: :lead_auditor) }


    let(:mail) { AuditMailer.notify_assignment(assignment) }

    it "has the correct subject" do
      expect(mail.subject).to eq("You have been assigned to audit ##{audit.id} as  #{assignment.role.to_s.humanize}")
    end

    it "sends the email to the correct address" do
      expect(mail.to).to eq([auditor.email])
    end

    it "has the correct sender email" do
      expect(mail.from).to eq(["mailhost.shef.ac.uk"])
    end

    it "includes the user's first name in the body" do
      expect(mail.body.encoded).to include("Hello #{auditor.first_name}")
    end

    it "includes the audit ID in the body" do
      expect(mail.body.encoded).to include("audit ##{audit.id}")
    end

    it "mentions the role in the email body" do
      expect(mail.body.encoded).to include("as #{assignment.role.to_s.humanize}")
    end
  end

  describe "update_audit" do
    let(:auditor) { create(:user, :auditor) }
    let(:qa_manager) { create(:user, :qa_manager) }


    let(:company) { create(:company) }
    let(:audit) { create(:audit, company: company) }
    let(:assignment) { create(:audit_assignment, user: auditor, assigned_by: qa_manager.id, audit: audit, role: :lead_auditor) }


    let(:mail) { AuditMailer.update_audit(assignment) }


    it "has the correct subject" do
      expect(mail.subject).to eq("Update to audit ##{audit.id}")
    end

    it "sends the email to the correct address" do
      expect(mail.to).to eq([auditor.email])
    end

    it "has the correct sender email" do
      expect(mail.from).to eq(["mailhost.shef.ac.uk"])
    end

    it "includes the user's first name in the body" do
      expect(mail.body.encoded).to include("Hello #{auditor.first_name}")
    end

    it "includes the audit ID in the body" do
      expect(mail.body.encoded).to include("Audit ##{audit.id}")
    end

    it "mentions the role in the email body" do
      expect(mail.body.encoded).to include("is #{assignment.role.to_s.humanize}")
    end

  end

end
