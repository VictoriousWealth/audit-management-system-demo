# == Schema Information
#
# Table name: audit_schedules
#
#  id             :bigint           not null, primary key
#  actual_end     :datetime
#  actual_start   :datetime
#  expected_end   :datetime
#  expected_start :datetime
#  status         :integer
#  task           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  audit_id       :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_audit_schedules_on_audit_id  (audit_id)
#  index_audit_schedules_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :audit_schedule do
    task { "MyString" }
    expected_start { "2025-03-12 16:37:59" }
    expected_end { "2025-03-12 16:37:59" }
    actual_start { "2025-03-12 16:37:59" }
    actual_end { "2025-03-12 16:37:59" }
    status { 1 }
    audit { nil }
    user { nil }
  end
end
