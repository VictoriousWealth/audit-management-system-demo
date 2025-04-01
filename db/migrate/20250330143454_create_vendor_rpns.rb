class CreateVendorRpns < ActiveRecord::Migration[7.0]
  def change
    create_table :vendor_rpns do |t|
      t.references :company, null: false, foreign_key: true
      t.datetime :time_of_creation, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.integer :material_criticality, null: false
      t.integer :supplier_compliance_history, null: false
      t.integer :regulatory_approvals, null: false
      t.integer :supply_chain_complexity, null: false
      t.integer :previous_supplier_performance, null: false
      t.integer :contamination_adulteration_risk, null: false

      t.timestamps
    end
  end
end
