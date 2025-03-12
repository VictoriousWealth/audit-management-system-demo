class CreateQuestionnaireSections < ActiveRecord::Migration[7.0]
  def change
    create_table :questionnaire_sections do |t|
      t.string :name
      t.integer :section_order

      t.timestamps
    end
  end
end
