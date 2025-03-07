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
FactoryBot.define do
  factory :contact do
    first_name { "MyString" }
    last_name { "MyString" }
    contact_email { "MyString" }
    contact_phone { "MyString" }
  end
end
