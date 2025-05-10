# == Schema Information
#
# Table name: audit_details
#
#  id         :bigint           not null, primary key
#  boundaries :string
#  objectives :string
#  purpose    :string
#  scope      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  audit_id   :bigint           not null
#
# Indexes
#
#  index_audit_details_on_audit_id  (audit_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#
require 'rails_helper'

RSpec.describe AuditDetail, type: :model do


  describe "associations" do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let(:audit_detail) { FactoryBot.create(:audit_detail, audit: audit) }
    it "belongs to an audit" do
      expect(audit_detail.audit).to eq(audit)
    end
  end

  describe "attributes" do 
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let(:audit_detail) { FactoryBot.create(:audit_detail, audit: audit) }
    it "has a scope" do
      expect(audit_detail.scope).to eq("The scope of test audit")
    end

    it "has a purpose" do
      expect(audit_detail.purpose).to eq("Purpose of test audit")
    end

    it "has objectives" do
      expect(audit_detail.objectives).to eq("Objectives of test audit")
    end

    it "has boundaries" do
      expect(audit_detail.boundaries).to eq("Boundaries of test audit")
    end
  end
end
