# == Schema Information
#
# Table name: audit_request_letters
#
#  id                   :bigint           not null, primary key
#  content              :string
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
#  index_audit_request_letters_on_audit_id  (audit_id)
#  index_audit_request_letters_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe AuditRequestLetter, type: :model do
  describe 'associations' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let!(:audit_request_letter) { FactoryBot.create(:audit_request_letter, audit: audit, user: user) }

    it "should belong to an audit" do
      expect(audit_request_letter.audit).to eq(audit)
    end
    it "should belong to a user" do
      expect(audit_request_letter.user).to eq(user)
    end
  end

  describe 'validations' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    
    it "should validate_presence_of #{(:user_id)}" do
      audit_request_letter = AuditRequestLetter.new(user_id: nil)
      expect(audit_request_letter).not_to be_valid
    end
    it "should validate_presence_of #{(:audit_id)}" do
      audit_request_letter = AuditRequestLetter.new(audit_id: nil)
      expect(audit_request_letter).not_to be_valid
      expect(audit_request_letter.errors[:audit_id]).to include("can't be blank")
    end
  end

  describe 'callbacks' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let!(:audit_request_letter) { FactoryBot.create(:audit_request_letter, audit: audit, user: user) }
    it 'sets time_of_creation before create if not already set' do
      letter = AuditRequestLetter.create!(
        content: 'Test content',
        audit: audit,
        user: user
      )

      expect(letter.time_of_creation).to be_present
      expect(letter.time_of_creation).to be_a(ActiveSupport::TimeWithZone)
    end

    it 'does not override time_of_creation if already set' do
      custom_time = 2.days.ago

      letter = AuditRequestLetter.create!(
        content: 'Test content',
        audit: audit,
        user: user,
        time_of_creation: custom_time
      )

      expect(letter.time_of_creation.to_i).to eq(custom_time.to_i)
    end
  end

  describe 'database columns' do
    let!(:company) { FactoryBot.create(:company) }
    let!(:user) { FactoryBot.create(:report_user) }
    let!(:audit) { FactoryBot.create(:audit, company: company) }
    let!(:audit_request_letter) { FactoryBot.create(:audit_request_letter, audit: audit, user: user) }

    it 'has a valid datetime for time_of_verification' do
      expect(audit_request_letter.time_of_verification).to be_a(ActiveSupport::TimeWithZone)

    end

    it 'has a valid datetime for time_of_distribution' do
      expect(audit_request_letter.time_of_distribution).to be_a(ActiveSupport::TimeWithZone)
    end
  end
end
