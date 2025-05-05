class ChangeReportIdToBeNullableInAuditFindings < ActiveRecord::Migration[7.0]
  def change
    change_column_null :audit_findings, :report_id, true
  end
end
