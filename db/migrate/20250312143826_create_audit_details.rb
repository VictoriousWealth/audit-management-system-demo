class CreateAuditDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_details do |t|
      t.string :scope
      t.string :purpose
      t.string :objectives
      t.string :boundaries

      t.timestamps
    end
  end
end
