class AddCustomQuestionnaireToQuestionnaireSection < ActiveRecord::Migration[7.0]
  def change
    add_reference :questionnaire_sections, :custom_questionnaire, null: false, foreign_key: true
  end
end
