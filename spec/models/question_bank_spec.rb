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
require 'rails_helper'

RSpec.describe QuestionBank, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
