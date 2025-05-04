class AddAssignedByToAuditAssignments < ActiveRecord::Migration[7.0]
  def change
    add_column :audit_assignments, :assigned_by, :bigint
  end
end
