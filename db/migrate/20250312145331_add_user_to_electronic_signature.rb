class AddUserToElectronicSignature < ActiveRecord::Migration[7.0]
  def change
    add_reference :electronic_signatures, :user, null: false, foreign_key: true
  end
end
