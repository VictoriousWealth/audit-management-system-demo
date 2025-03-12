class CreateResponseChoices < ActiveRecord::Migration[7.0]
  def change
    create_table :response_choices do |t|
      t.integer :response_type
      t.string :response_text

      t.timestamps
    end
  end
end
