class AddAuditTypeToAudits < ActiveRecord::Migration[7.0]
  def change
    add_column :audits, :audit_type, :string
  end
end
