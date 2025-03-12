class CreateDocumentUpdates < ActiveRecord::Migration[7.0]
  def change
    create_table :document_updates do |t|
      t.datetime :time_updated
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
