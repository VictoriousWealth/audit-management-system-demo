# == Schema Information
#
# Table name: question_banks
#
#  id            :bigint           not null, primary key
#  category      :integer
#  question_text :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :question_bank do
    question_text { "MyString" }
    category { 1 }
  end
end
