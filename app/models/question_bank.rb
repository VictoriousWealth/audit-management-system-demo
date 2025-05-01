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
class QuestionBank < ApplicationRecord
  has_many :section_questions
  has_many :questionnaire_sections, through: :section_questions
  
  has_many :responses
end
