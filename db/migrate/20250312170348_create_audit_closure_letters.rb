class CreateAuditClosureLetters < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_closure_letters do |t|
      t.string :content
      t.datetime :time_of_creation
      t.datetime :time_of_verification
      t.datetime :time_of_distribution

      t.timestamps
    end
  end
end
