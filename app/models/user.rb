# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string
#  first_name :string
#  last_name  :string
#  password   :string
#  role       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :bigint
#
# Indexes
#
#  index_users_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class User < ApplicationRecord
  enum role:{
    auditor: 0,
    auditee: 1,
    qa_manager: 2,
    senior_manager: 3,
  }

  has_many :audit_assignments
  has_one :company, optional: true
  has_many :audits
  has_many :electronic_signatures
  has_many :login_attempts
  has_many :custom_questionnaires
  has_many :document_updates
  has_many :audit_logs
  has_many :audit_schedules
  has_many :audit_closure_letters
  has_many :reports
end
