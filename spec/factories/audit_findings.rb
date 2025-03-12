# == Schema Information
#
# Table name: audit_findings
#
#  id                   :bigint           not null, primary key
#  category             :integer
#  description          :string
#  risk_level           :integer
#  time_of_creation     :datetime
#  time_of_distribution :datetime
#  time_of_verification :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
FactoryBot.define do
  factory :audit_finding do
    description { "MyString" }
    category { 1 }
    risk_level { 1 }
    time_of_creation { "2025-03-07 14:05:46" }
    time_of_verification { "2025-03-07 14:05:46" }
    time_of_distribution { "MyString" }
    datetime { "MyString" }
  end
end
