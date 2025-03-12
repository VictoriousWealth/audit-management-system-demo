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
FactoryBot.define do
  factory :questionnaire_section do
    name { "MyString" }
    section_order { 1 }
  end
end
