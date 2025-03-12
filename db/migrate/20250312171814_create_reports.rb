class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.integer :status
      t.datetime :time_of_creation
      t.datetime :time_of_verification
      t.datetime :time_of_distribution
      t.references :audit, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :audit_finding, null: false, foreign_key: true

      t.timestamps
    end
  end
end
