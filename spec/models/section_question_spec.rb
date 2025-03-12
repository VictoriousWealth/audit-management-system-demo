# == Schema Information
#
# Table name: section_questions
#
#  id                       :bigint           not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  question_bank_id         :bigint           not null
#  questionnaire_section_id :bigint           not null
#
# Indexes
#
#  index_section_questions_on_question_bank_id          (question_bank_id)
#  index_section_questions_on_questionnaire_section_id  (questionnaire_section_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_bank_id => question_banks.id)
#  fk_rails_...  (questionnaire_section_id => questionnaire_sections.id)
#
require 'rails_helper'

RSpec.describe SectionQuestion, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
