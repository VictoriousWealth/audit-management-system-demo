class RemoveAddressFromCompanies < ActiveRecord::Migration[7.0]
  def change
    remove_column :companies, :address, :string
  end
end
