# == Schema Information
#
# Table name: audit_request_letters
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
#  index_audit_request_letters_on_audit_id  (audit_id)
#  index_audit_request_letters_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe AuditRequestLetter, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
