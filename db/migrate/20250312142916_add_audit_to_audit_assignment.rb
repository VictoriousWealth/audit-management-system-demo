class AddAuditToAuditAssignment < ActiveRecord::Migration[7.0]
  def change
    add_reference :audit_assignments, :audit, null: false, foreign_key: true
  end
end
