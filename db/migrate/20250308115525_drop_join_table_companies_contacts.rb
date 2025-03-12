class DropJoinTableCompaniesContacts < ActiveRecord::Migration[7.0]
  def change
    drop_table :companies_contacts
  end
end
