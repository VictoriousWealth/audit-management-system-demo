class CreateElectronicSignatures < ActiveRecord::Migration[7.0]
  def change
    create_table :electronic_signatures do |t|
      t.datetime :signed_at
      t.integer :signature_type

      t.timestamps
    end
  end
end
