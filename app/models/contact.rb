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
class Contact < ApplicationRecord
  has_one :company_contact, dependent: :destroy
  has_one :company, through: :company_contact
end
