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
class QuestionBank < ApplicationRecord
  enum category:{
    general: 0,
    compliance: 1,
    safety: 2,
  }
  belongs_to :section_question, optional: true
  has_many :response_choices
end
