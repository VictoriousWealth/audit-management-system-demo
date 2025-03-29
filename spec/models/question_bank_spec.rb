# == Schema Information
#
# Table name: question_banks
#
#  id                  :bigint           not null, primary key
#  category            :string
#  question_text       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  response_choices_id :bigint
#
# Indexes
#
#  index_question_banks_on_response_choices_id  (response_choices_id)
#
# Foreign Keys
#
#  fk_rails_...  (response_choices_id => response_choices.id)
#
require 'rails_helper'

RSpec.describe QuestionBank, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
