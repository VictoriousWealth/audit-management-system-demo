# == Schema Information
#
# Table name: companies
#
#  id          :bigint           not null, primary key
#  city        :string
#  name        :string
#  postcode    :string
#  street_name :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :company do
    name { "Company 1" }
    street_name { "Street 1" }
    city { "City 1" }
    postcode { "12345" }
  end
end
