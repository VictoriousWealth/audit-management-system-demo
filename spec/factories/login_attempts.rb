# == Schema Information
#
# Table name: login_attempts
#
#  id           :bigint           not null, primary key
#  attempt_time :datetime
#  ip_address   :string
#  success      :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_login_attempts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :login_attempt do
    attempt_time { "2025-03-07 13:53:35" }
    success { false }
    ip_address { "MyString" }
  end
end
