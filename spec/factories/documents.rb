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
FactoryBot.define do
  factory :document do
    name { "MyString" }
    document_type { "MyString" }
    uploaded_at { "2025-03-12 16:29:08" }
    content { "MyString" }
    location { "MyString" }
  end
end
