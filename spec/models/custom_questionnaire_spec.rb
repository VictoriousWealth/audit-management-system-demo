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
require 'rails_helper'

RSpec.describe CustomQuestionnaire, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
