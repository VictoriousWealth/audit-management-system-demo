class AddUserToCustomQuestionnaire < ActiveRecord::Migration[7.0]
  def change
    add_reference :custom_questionnaires, :user, null: false, foreign_key: true
  end
end
