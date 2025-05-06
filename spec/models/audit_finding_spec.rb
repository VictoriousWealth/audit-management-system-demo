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
#  report_id   :bigint
#
# Indexes
#
#  index_audit_findings_on_report_id  (report_id)
#
# Foreign Keys
#
#  fk_rails_...  (report_id => reports.id)
#
require 'rails_helper'

RSpec.describe AuditFinding, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
