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
class CorrectiveAction < ApplicationRecord
  enum status: { 
    pending: 0, 
    in_progress: 1,
    completed: 2 
  }
  belongs_to :audit, optional: true
end
