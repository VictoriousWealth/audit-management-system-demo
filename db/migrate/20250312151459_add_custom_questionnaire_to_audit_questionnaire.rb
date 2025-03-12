class AddCustomQuestionnaireToAuditQuestionnaire < ActiveRecord::Migration[7.0]
  def change
    add_reference :audit_questionnaires, :custom_questionnaire, null: false, foreign_key: true
  end
end
