# == Schema Information
#
# Table name: selected_responses
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  response_choice_id :bigint           not null
#
# Indexes
#
#  index_selected_responses_on_response_choice_id  (response_choice_id)
#
# Foreign Keys
#
#  fk_rails_...  (response_choice_id => response_choices.id)
#
require 'rails_helper'

RSpec.describe SelectedResponse, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
