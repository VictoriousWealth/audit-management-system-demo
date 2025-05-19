# == Schema Information
#
# Table name: audit_standards
#
#  id              :bigint           not null, primary key
#  standard        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  audit_detail_id :bigint           not null
#
# Indexes
#
#  index_audit_standards_on_audit_detail_id  (audit_detail_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_detail_id => audit_details.id)
#
FactoryBot.define do
  factory :audit_standard do
    standard { "Standard 1" }
  end
end
