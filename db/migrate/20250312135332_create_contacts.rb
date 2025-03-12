class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :contact_email
      t.string :contact_phone
      t.boolean :representative_contact
      t.string :additional_notes

      t.timestamps
    end
  end
end
