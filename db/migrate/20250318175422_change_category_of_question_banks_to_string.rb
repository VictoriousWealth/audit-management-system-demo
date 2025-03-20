class ChangeCategoryOfQuestionBanksToString < ActiveRecord::Migration[7.0]
  def change
    change_column(:question_banks, :category, :string)
  end
end
