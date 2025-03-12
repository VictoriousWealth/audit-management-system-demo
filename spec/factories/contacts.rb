# == Schema Information
#
# Table name: contacts
#
#  id                     :bigint           not null, primary key
#  additional_notes       :string
#  contact_email          :string
#  contact_phone          :string
#  first_name             :string
#  last_name              :string
#  representative_contact :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :bigint           not null
#
# Indexes
#
#  index_contacts_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
FactoryBot.define do
  factory :contact do
    first_name { "MyString" }
    last_name { "MyString" }
    contact_email { "MyString" }
    contact_phone { "MyString" }
    representative_contact { false }
    additional_notes { "MyString" }
  end
end
