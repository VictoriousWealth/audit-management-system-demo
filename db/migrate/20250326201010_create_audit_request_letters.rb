class CreateAuditRequestLetters < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_request_letters do |t|
      t.references :audit, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :content
      t.datetime :time_of_creation
      t.datetime :time_of_verification
      t.datetime :time_of_distribution

      t.timestamps
    end
  end
end
