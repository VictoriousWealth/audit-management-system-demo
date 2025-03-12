class AddAuditDetailToAuditStandard < ActiveRecord::Migration[7.0]
  def change
    add_reference :audit_standards, :audit_detail, null: false, foreign_key: true
  end
end
