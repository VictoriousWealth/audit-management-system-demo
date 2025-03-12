class AddCompanyToAudit < ActiveRecord::Migration[7.0]
  def change
    add_reference :audits, :company, null: false, foreign_key: true
  end
end
