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
class SupportingDocument < ApplicationRecord
  belongs_to :audit, optional: true
end
