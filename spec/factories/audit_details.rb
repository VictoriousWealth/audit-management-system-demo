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
    # association :audit

    scope { "The scope of the test audit" }
    purpose { "The purpose of the test audit" }
    objectives { "The objectives of the test audit" }
    boundaries { "The boundaries of the test audit" }

    # Optional: create with associated audit_standards
    trait :with_standards do
      after(:create) do |audit_detail|
        create_list(:audit_standard, 3, audit_detail: audit_detail)
      end
    end
  end
end
