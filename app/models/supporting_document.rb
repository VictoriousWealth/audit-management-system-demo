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
#  user_id     :bigint           not null
#
# Indexes
#
#  index_supporting_documents_on_audit_id  (audit_id)
#  index_supporting_documents_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
class SupportingDocument < ApplicationRecord

  belongs_to :audit, optional: true
  has_one_attached :file
  belongs_to :user


  # Should set the uploaded time when one is made
  before_create :set_uploaded_at

  private

  def set_uploaded_at
    self.uploaded_at = Time.current
  end
end
