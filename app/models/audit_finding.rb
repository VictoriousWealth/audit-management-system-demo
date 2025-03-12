# == Schema Information
#
# Table name: audit_findings
#
#  id          :bigint           not null, primary key
#  category    :integer
#  description :string
#  due_date    :datetime
#  risk_level  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  report_id   :bigint           not null
#
# Indexes
#
#  index_audit_findings_on_report_id  (report_id)
#
# Foreign Keys
#
#  fk_rails_...  (report_id => reports.id)
#
class AuditFinding < ApplicationRecord
  enum category:{
    critical: 0,
    major: 1,
    minor: 2,
  }

  enum risk_level:{
    low: 0,
    medium: 1,
    high: 2,
  }

  belongs_to :report, optional: true
end
