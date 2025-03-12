class AddUserToAuditClosureLetter < ActiveRecord::Migration[7.0]
  def change
    add_reference :audit_closure_letters, :user, null: false, foreign_key: true
  end
end
