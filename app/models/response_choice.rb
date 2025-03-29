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
class ResponseChoice < ApplicationRecord
  enum response_choice: {
    yes: 1,
    no: 2,
    non_applicable: 3,
  }
  belongs_to :question_bank
  has_one :selected_response, required: false
end
