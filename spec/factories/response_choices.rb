# == Schema Information
#
# Table name: response_choices
#
#  id            :bigint           not null, primary key
#  response_text :string
#  response_type :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :response_choice do
    response_type { 1 }
    response_text { "MyString" }
  end
end
