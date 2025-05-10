# == Schema Information
#
# Table name: audit_assignments
#
#  id            :bigint           not null, primary key
#  assigned_by   :bigint
#  role          :integer
#  status        :integer
#  time_accepted :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  audit_id      :bigint           not null
#  user_id       :bigint           not null
#
FactoryBot.define do
  factory :audit_assignment do
    role { 1 }
    status { 1 }
    time_accepted { "2025-03-12 14:02:42" }
    user { 1 }
  end
end
