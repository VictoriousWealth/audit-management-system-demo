class CreateSelectedResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :selected_responses do |t|
      t.references :response_choice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
