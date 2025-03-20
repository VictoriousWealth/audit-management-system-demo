class RemoveAuditAssignmentsIdFromAuditAssignments < ActiveRecord::Migration[7.0]
  def change
    remove_column :audit_assignments, :audit_assignments_id, :bigint
  end
end
