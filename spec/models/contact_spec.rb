# == Schema Information
#
# Table name: contacts
#
#  id            :bigint           not null, primary key
#  contact_email :string
#  contact_phone :string
#  first_name    :string
#  last_name     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe Contact, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
