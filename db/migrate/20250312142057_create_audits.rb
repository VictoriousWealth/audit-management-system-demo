class CreateAudits < ActiveRecord::Migration[7.0]
  def change
    create_table :audits do |t|
      t.datetime :scheduled_start_date
      t.datetime :scheduled_end_date
      t.datetime :actual_start_date
      t.datetime :actual_end_date
      t.integer :status
      t.integer :score
      t.integer :final_outcome
      t.datetime :time_of_creation
      t.datetime :time_of_verification
      t.datetime :time_of_closure

      t.timestamps
    end
  end
end
