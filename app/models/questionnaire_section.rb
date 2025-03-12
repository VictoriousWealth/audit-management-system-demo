# == Schema Information
#
# Table name: questionnaire_sections
#
#  id                      :bigint           not null, primary key
#  name                    :string
#  section_order           :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  custom_questionnaire_id :bigint           not null
#
# Indexes
#
#  index_questionnaire_sections_on_custom_questionnaire_id  (custom_questionnaire_id)
#
# Foreign Keys
#
#  fk_rails_...  (custom_questionnaire_id => custom_questionnaires.id)
#
class QuestionnaireSection < ApplicationRecord
  belongs_to :custom_questionnaire, optional: true
  has_many :section_questions
  has_many :question_banks, through: :section_questions
end
