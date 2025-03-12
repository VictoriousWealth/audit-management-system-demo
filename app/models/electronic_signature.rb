# == Schema Information
#
# Table name: electronic_signatures
#
#  id             :bigint           not null, primary key
#  signature_type :integer
#  signed_at      :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class ElectronicSignature < ApplicationRecord
end
