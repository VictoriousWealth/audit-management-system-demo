class AddResponseToQuestionBanks < ActiveRecord::Migration[7.0]
  def change
    add_reference :question_banks, :response_choices, foreign_key: true
  end
end
