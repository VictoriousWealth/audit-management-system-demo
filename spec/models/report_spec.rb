# == Schema Information
#
# Table name: reports
#
#  id                   :bigint           not null, primary key
#  status               :integer
#  time_of_creation     :datetime
#  time_of_distribution :datetime
#  time_of_verification :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  audit_id             :bigint           not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_reports_on_audit_id  (audit_id)
#  index_reports_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Report, type: :model do

  describe 'associations' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let!(:report) { FactoryBot.create(:report, audit: audit, user: user) }

    it "Should belong to audit" do
      # Check if the report belongs to the audit
      expect(report.audit).to eq(audit)
    end

    it "Should belong to user" do
      # Check if the report belongs to the user
      expect(report.user).to eq(user)
    end
    it "should have many audit findings" do
      # Create a new audit finding instance associated with the report
      audit_finding1 = AuditFinding.create!(report: report)
      audit_finding2 = AuditFinding.create!(report: report)
      # Check if the report has the audit findings
      expect(report.audit_findings).to include(audit_finding1)
      expect(report.audit_findings).to include(audit_finding2)
    end
  end

  describe 'enums' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    # let!(:report) { FactoryBot.create(:report, audit: audit, user: user) }
    
    it "should define enum for status" do
      # Create a new report instance
      report = FactoryBot.create(:report, audit: audit, user: user, status: :in_progress)
      # Check if the status is set correctly
      expect(report.status).to eq("in_progress")
    end

    it "should update status enum" do
      # Create a new report instance
      report = FactoryBot.create(:report, audit: audit, user: user, status: :in_progress)

      # Update the status
      report.update(status: :generated)

      # Check if the status is updated correctly
      expect(report.status).to eq("generated")
    end
  end

  describe 'database columns' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let!(:report) { FactoryBot.create(:report, audit: audit, user: user, status: :in_progress) }
    it "should have column status" do
      # Check if the status column exists
      expect(report).to have_attributes(status: a_kind_of(String))
    end
    it "should have column time_of_creation" do
      # Check if the time_of_creation column exists
      expect(report.time_of_creation).to be_a(ActiveSupport::TimeWithZone)

      
    end
    it "should have column time_of_distribution" do
      # Check if the time_of_distribution column exists
      expect(report.time_of_distribution).to be_a(ActiveSupport::TimeWithZone)

    end
    it "should have column time_of_verification" do
      # Check if the time_of_verification column exists

      expect(report.time_of_verification).to be_a(ActiveSupport::TimeWithZone)

    end

    it "should have column audit_id" do
      # Check if the audit_id column exists
      expect(report).to have_attributes(audit_id: a_kind_of(Integer))
    end
    it "should have column user_id" do
      # Check if the user_id column exists
      expect(report).to have_attributes(user_id: a_kind_of(Integer))
    end
  end
end
