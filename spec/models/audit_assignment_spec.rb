# == Schema Information
#
# Table name: audit_assignments
#
#  id                   :bigint           not null, primary key
#  role                 :integer
#  status               :integer
#  time_accepted        :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  audit_assignments_id :bigint           not null
#  audit_id             :bigint           not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_audit_assignments_on_audit_assignments_id  (audit_assignments_id)
#  index_audit_assignments_on_audit_id              (audit_id)
#  index_audit_assignments_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_assignments_id => audit_assignments.id)
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe AuditAssignment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
