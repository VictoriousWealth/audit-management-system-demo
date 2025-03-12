class AddAuditToAuditQuestionnaire < ActiveRecord::Migration[7.0]
  def change
    add_reference :audit_questionnaires, :audit, null: false, foreign_key: true
  end
end
