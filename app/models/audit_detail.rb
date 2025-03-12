# == Schema Information
#
# Table name: audit_details
#
#  id         :bigint           not null, primary key
#  boundaries :string
#  objectives :string
#  purpose    :string
#  scope      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  audit_id   :bigint           not null
#
# Indexes
#
#  index_audit_details_on_audit_id  (audit_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#
class AuditDetail < ApplicationRecord
  belongs_to :audit
  has_many :audit_standards
end
