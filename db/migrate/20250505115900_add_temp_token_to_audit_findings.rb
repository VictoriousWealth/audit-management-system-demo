class AddTempTokenToAuditFindings < ActiveRecord::Migration[7.0]
  def change
    add_column :audit_findings, :temp_token, :string
  end
end
