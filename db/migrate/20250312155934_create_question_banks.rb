class CreateQuestionBanks < ActiveRecord::Migration[7.0]
  def change
    create_table :question_banks do |t|
      t.string :question_text
      t.integer :category

      t.timestamps
    end
  end
end
