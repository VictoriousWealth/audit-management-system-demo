class AddAuditToAuditClosureLetter < ActiveRecord::Migration[7.0]
  def change
    add_reference :audit_closure_letters, :audit, null: false, foreign_key: true
  end
end
