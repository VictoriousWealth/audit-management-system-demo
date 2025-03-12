class CreateCustomQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_questionnaires do |t|
      t.string :name
      t.datetime :time_of_creation
      t.datetime :time_of_response

      t.timestamps
    end
  end
end
