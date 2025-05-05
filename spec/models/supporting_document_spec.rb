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

require 'rails_helper'

RSpec.describe SupportingDocument, type: :model do

  describe "file attachment" do
    it "can have a file attached" do
      document = SupportingDocument.new
      document.file.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/sample.pdf")),
        filename: "sample.pdf",
        content_type: "application/pdf"
      )
      expect(document.file).to be_attached
    end
  end
end
