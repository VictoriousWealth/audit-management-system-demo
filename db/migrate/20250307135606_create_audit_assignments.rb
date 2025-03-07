class CreateAuditAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_assignments do |t|
      t.integer :role
      t.integer :status
      t.datetime :time_accepted

      t.timestamps
    end
  end
end
