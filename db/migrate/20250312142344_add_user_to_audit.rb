class AddUserToAudit < ActiveRecord::Migration[7.0]
  def change
    add_reference :audits, :user, null: true, foreign_key: true
  end
end
