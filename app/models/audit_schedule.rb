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
class AuditSchedule < ApplicationRecord
  enum status:{
    completed: 0,
    on_time: 1,
    late: 2,
  }
  belongs_to :audit, optional: true
  belongs_to :user, optional: true
end
