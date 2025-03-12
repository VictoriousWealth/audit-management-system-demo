class CreateSectionQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :section_questions do |t|
      t.references :questionnaire_section, null: false, foreign_key: true
      t.references :question_bank, null: false, foreign_key: true

      t.timestamps
    end
  end
end
