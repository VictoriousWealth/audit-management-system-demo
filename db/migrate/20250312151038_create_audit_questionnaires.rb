class CreateAuditQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_questionnaires do |t|
      t.datetime :time_of_verification
      t.datetime :time_of_distribution

      t.timestamps
    end
  end
end
