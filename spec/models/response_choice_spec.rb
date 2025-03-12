# == Schema Information
#
# Table name: response_choices
#
#  id            :bigint           not null, primary key
#  response_text :string
#  response_type :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe ResponseChoice, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
