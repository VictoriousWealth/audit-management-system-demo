# == Schema Information
#
# Table name: supporting_documents
#
#  id          :bigint           not null, primary key
#  content     :string
#  location    :string
#  name        :string
#  uploaded_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  audit_id    :bigint           not null
#
# Indexes
#
#  index_supporting_documents_on_audit_id  (audit_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#
require 'rails_helper'

RSpec.describe SupportingDocument, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
