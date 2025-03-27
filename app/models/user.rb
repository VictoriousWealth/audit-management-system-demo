# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer
#  sign_in_count          :integer          default(0), not null
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
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role:{
    auditor: 0,
    auditee: 1,
    qa_manager: 2,
    senior_manager: 3,
    sme: 4,
  }

  has_many :audit_assignments
  belongs_to :company, optional: true 
  has_many :audits
  has_many :electronic_signatures
  has_many :login_attempts
  has_many :custom_questionnaires
  has_many :document_updates
  has_many :audit_logs
  has_many :audit_schedules
  has_many :audit_closure_letters
  has_many :reports
  has_many :audit_request_letters

  def full_name
    "#{first_name} #{last_name}"
  end
end
