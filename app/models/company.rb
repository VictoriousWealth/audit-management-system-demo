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
class Company < ApplicationRecord
  has_many :users
  has_many :audits
  has_many :contacts
  has_many :vendor_rpns, dependent: :destroy
end

