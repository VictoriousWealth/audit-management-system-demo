# == Schema Information
#
# Table name: custom_questionnaires
#
#  id               :bigint           not null, primary key
#  name             :string
#  time_of_creation :datetime
#  time_of_response :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_custom_questionnaires_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :custom_questionnaire do
    name { "MyString" }
    time_of_creation { "2025-03-12 15:06:50" }
    time_of_response { "2025-03-12 15:06:50" }
  end
end
