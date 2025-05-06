class RemoveTempTokenFromAuditFindings < ActiveRecord::Migration[7.0]
  def change
    remove_column :audit_findings, :temp_token, :string
  end
end