# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string
#  last_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer
#  sign_in_count          :integer          default(0), not null
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :bigint
#
# Indexes
#
#  index_users_on_company_id            (company_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
FactoryBot.define do

  #Auditee
  factory :user do
    first_name { "Auditee" }
    last_name { "User" }
    email { "Auditee@User.com" }
    password { "Password" }
    role { 1 }
  end

  #QA manager
  factory :user2, class: 'User' do
    first_name { "QA" }
    last_name { "User" }
    email { "QA@User.com" }
    password { "Password" }
    role { 2 }
  end

  #QA manager
  factory :user3, class: 'User' do
    first_name { "Senior" }
    last_name { "User" }
    email { "Senior@User.com" }
    password { "Password" }
    role { 3 }
  end

  #QA manager
  factory :user4, class: 'User' do
    first_name { "Auditor" }
    last_name { "User" }
    email { "Auditor@User.com" }
    password { "Password" }
    role { 0 }
  end
end
