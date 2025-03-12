# == Schema Information
#
# Table name: electronic_signatures
#
#  id             :bigint           not null, primary key
#  signature_type :integer
#  signed_at      :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  audit_id       :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_electronic_signatures_on_audit_id  (audit_id)
#  index_electronic_signatures_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe ElectronicSignature, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
