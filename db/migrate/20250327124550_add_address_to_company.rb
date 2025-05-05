class AddAddressToCompany < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :street_name, :string
    add_column :companies, :city, :string
    add_column :companies, :postcode, :string
  end
end
