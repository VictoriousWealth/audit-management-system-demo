# == Schema Information
#
# Table name: audit_assignments
#
#  id            :bigint           not null, primary key
#  assigned_by   :bigint
#  role          :integer
#  status        :integer
#  time_accepted :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  audit_id      :bigint           not null
#  user_id       :bigint           not null
#
class AuditAssignment < ApplicationRecord
  enum role: {
    lead_auditor: 0,
    auditor: 1,
    sme: 2,
    auditee: 3,
  }

  enum status: {
    assigned: 0,
    accepted: 1,
    declined: 2,
  }
  belongs_to :user
  belongs_to :audit
  belongs_to :assigner, class_name: "User", foreign_key: "assigned_by"

end
