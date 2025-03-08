# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  address    :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Company < ApplicationRecord
  has_many :company_contacts, dependent: :destroy
  has_many :contacts, through: :company_contacts
end
