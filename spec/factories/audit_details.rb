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
FactoryBot.define do
  factory :audit_detail do
    scope { "The scope of test audit" }
    purpose { "Purpose of test audit" }
    objectives { "Objectives of test audit" }
    boundaries { "Boundaries of test audit" }
  end
end
