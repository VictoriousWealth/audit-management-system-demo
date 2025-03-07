# == Schema Information
#
# Table name: audit_assignments
#
#  id            :bigint           not null, primary key
#  role          :integer
#  status        :integer
#  time_accepted :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :audit_assignment do
    role { 1 }
    status { 1 }
    time_accepted { "2025-03-07 13:56:07" }
  end
end
