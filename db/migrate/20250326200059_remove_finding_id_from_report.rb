class RemoveFindingIdFromReport < ActiveRecord::Migration[7.0]
  def change
    remove_column :reports, :audit_finding_id, :bigint
  end
end
