class CreateAuditStandards < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_standards do |t|
      t.string :standard

      t.timestamps
    end
  end
end
