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
<<<<<<< HEAD
=======
    name { "Company 1" }
    street_name { "Street 1" }
    city { "City 1" }
    postcode { "12345" }
>>>>>>> 187d30bf269f1c427642d901d03433805557c483
  end
end
