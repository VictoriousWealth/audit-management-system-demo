# == Schema Information
#
# Table name: corrective_actions
#
#  id                   :bigint           not null, primary key
#  action_description   :string
#  due_date             :datetime
#  status               :integer
#  time_of_creation     :datetime
#  time_of_distribution :datetime
#  time_of_verification :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  audit_id             :bigint           not null
#
# Indexes
#
#  index_corrective_actions_on_audit_id  (audit_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#
FactoryBot.define do
  factory :corrective_action do
    audit { nil }
    action_description { "MyString" }
    due_date { "2025-03-12 17:10:20" }
    status { 1 }
    time_of_creation { "2025-03-12 17:10:20" }
    time_of_verification { "2025-03-12 17:10:20" }
    time_of_distribution { "2025-03-12 17:10:20" }
  end
end
