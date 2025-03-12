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
#  audit_finding_id     :bigint           not null
#  audit_id             :bigint           not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_reports_on_audit_finding_id  (audit_finding_id)
#  index_reports_on_audit_id          (audit_id)
#  index_reports_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_finding_id => audit_findings.id)
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Report, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
