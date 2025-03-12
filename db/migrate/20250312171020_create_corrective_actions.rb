class CreateCorrectiveActions < ActiveRecord::Migration[7.0]
  def change
    create_table :corrective_actions do |t|
      t.references :audit, null: false, foreign_key: true
      t.string :action_description
      t.datetime :due_date
      t.integer :status
      t.datetime :time_of_creation
      t.datetime :time_of_verification
      t.datetime :time_of_distribution

      t.timestamps
    end
  end
end
