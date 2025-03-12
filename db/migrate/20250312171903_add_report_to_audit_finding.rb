class AddReportToAuditFinding < ActiveRecord::Migration[7.0]
  def change
    add_reference :audit_findings, :report, null: false, foreign_key: true
  end
end
