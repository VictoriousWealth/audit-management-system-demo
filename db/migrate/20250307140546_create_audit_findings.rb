class CreateAuditFindings < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_findings do |t|
      t.string :description
      t.integer :category
      t.integer :risk_level
      t.datetime :time_of_creation
      t.datetime :time_of_verification
      t.datetime :time_of_distribution

      t.timestamps
    end
  end
end
