class AddAuditToSupportingDocument < ActiveRecord::Migration[7.0]
  def change
    add_reference :supporting_documents, :audit, null: false, foreign_key: true
  end
end
