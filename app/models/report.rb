# == Schema Information
#
# Table name: reports
#
#  id                   :bigint           not null, primary key
#  status               :integer
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
#  index_reports_on_audit_id  (audit_id)
#  index_reports_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
class Report < ApplicationRecord
  enum status:{
    in_progress: 0,
    generated: 1,
    sent: 2,
  }
  belongs_to :audit, optional: true
  belongs_to :user, optional: true
  has_many :audit_findings
end
