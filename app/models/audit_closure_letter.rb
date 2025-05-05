# == Schema Information
#
# Table name: audit_closure_letters
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
#  index_audit_closure_letters_on_audit_id  (audit_id)
#  index_audit_closure_letters_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
class AuditClosureLetter < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :audit

  validates :content, presence: true
  validates :audit_id, presence: true

  before_create :set_creation_time

  attr_accessor :overall_compliance, :summary_statement, :auditee_acknowledged, :auditor_acknowledged

  private

  def set_creation_time
    self.time_of_creation ||= Time.current
  end
end
