class CreateAuditSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_schedules do |t|
      t.string :task
      t.datetime :expected_start
      t.datetime :expected_end
      t.datetime :actual_start
      t.datetime :actual_end
      t.integer :status
      t.references :audit, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
