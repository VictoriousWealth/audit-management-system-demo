# == Schema Information
#
# Table name: documents
#
#  id            :bigint           not null, primary key
#  content       :string
#  document_type :string
#  location      :string
#  name          :string
#  uploaded_at   :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Document < ApplicationRecord
  has_many :document_updates
end
