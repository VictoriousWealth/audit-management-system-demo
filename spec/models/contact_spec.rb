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
require 'rails_helper'

RSpec.describe Contact, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
