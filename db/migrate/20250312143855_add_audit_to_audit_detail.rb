class AddAuditToAuditDetail < ActiveRecord::Migration[7.0]
  def change
    add_reference :audit_details, :audit, null: false, foreign_key: true
  end
end
