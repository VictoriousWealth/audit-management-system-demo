# == Schema Information
#
# Table name: audit_findings
#
#  id          :bigint           not null, primary key
#  category    :integer
#  description :string
#  due_date    :datetime
#  risk_level  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  report_id   :bigint
#
# Indexes
#
#  index_audit_findings_on_report_id  (report_id)
#
# Foreign Keys
#
#  fk_rails_...  (report_id => reports.id)
#
require 'rails_helper'

RSpec.describe AuditFinding, type: :model do


  describe 'associations' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let!(:report) { FactoryBot.create(:report, audit: audit, user: user) }

    it "should belong to a report" do
      audit_finding = FactoryBot.create(:audit_finding, report: report)
      expect(audit_finding.report).to eq(report)
    end
  end

  describe 'enums' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let!(:report) { FactoryBot.create(:report, audit: audit, user: user) }

    it "should define enum for category" do
      expect(AuditFinding.defined_enums).to include("category")
      expect(AuditFinding.defined_enums["category"]).to eq({"critical" => 0, "major" => 1, "minor" => 2})
    end
    it "should define enum for risk_level" do
      expect(AuditFinding.defined_enums).to include("risk_level")
      expect(AuditFinding.defined_enums["risk_level"]).to eq({"low" => 0, "medium" => 1, "high" => 2})
    end
  end

  describe 'attributes' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let!(:report) { FactoryBot.create(:report, audit: audit, user: user) }
    let!(:finding) { FactoryBot.create(:audit_finding, report: report) }

    it 'has a due_date that is a Time object' do
      expect(finding.due_date).to be_a(ActiveSupport::TimeWithZone)
    end

    it 'returns the correct enum value for category' do
      finding.category = :major
      expect(finding.category).to eq("major")
    end

    it 'returns the correct enum value for risk_level' do
      finding.risk_level = :high
      expect(finding.risk_level).to eq("high")
    end
    it 'returns the correct description' do
      finding.description = "Test description"
      expect(finding.description).to eq("Test description")
    end
  end
end
