# == Schema Information
#
# Table name: audit_logs
#
#  id         :bigint           not null, primary key
#  log_action :string
#  timestamp  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  audit_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_audit_logs_on_audit_id  (audit_id)
#  index_audit_logs_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
