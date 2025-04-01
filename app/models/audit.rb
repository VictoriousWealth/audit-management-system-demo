# == Schema Information
#
# Table name: audits
#
#  id                   :bigint           not null, primary key
#  actual_end_date      :datetime
#  actual_start_date    :datetime
#  audit_type           :string
#  final_outcome        :integer
#  scheduled_end_date   :datetime
#  scheduled_start_date :datetime
#  score                :integer
#  status               :integer
#  time_of_closure      :datetime
#  time_of_creation     :datetime
#  time_of_verification :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  company_id           :bigint           not null
#  user_id              :bigint
#
# Indexes
#
#  index_audits_on_company_id  (company_id)
#  index_audits_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (user_id => users.id)
#
class Audit < ApplicationRecord

  enum status: {
    not_started: 0,
    in_progress: 1,
    pending_review: 2,
    completed: 3,
    cancelled: 4,
  }

  enum final_outcome: {
    pass: 0,
    fail: 1,
  }

  enum audit_type: {
    internal: "internal",
    external: "external"
  }
  
  belongs_to :company, optional: true
  belongs_to :user, optional: true
  has_many :audit_assignments, dependent: :destroy
  has_one :audit_detail, dependent: :destroy
  has_many :supporting_documents
  has_many :electronic_signatures
  has_many :audit_logs
  has_many :audit_schedules
  has_many :audit_questionnaires
  has_one :audit_closure_letter
  has_many :corrective_actions
  has_many :reports
  has_one :audit_request_letter

  accepts_nested_attributes_for :audit_assignments, allow_destroy: true
  accepts_nested_attributes_for :audit_detail, allow_destroy: true




  def auditors
    audit_assignments.includes(:user).where(role: :auditor).map do |assignment|
      user = assignment.user
      user ? "#{user.first_name} #{user.last_name}" : "N/A"
    end.join(', ')
  end

  def smes
    audit_assignments.includes(:user).where(role: :sme).map do |assignment|
      user = assignment.user
      user ? "#{user.first_name} #{user.last_name}" : "N/A"
    end.join(', ')
  end

  def formatted_auditors
    assignments = audit_assignments.includes(:user)
  
    lead = assignments.find { |a| a.role == "lead_auditor" }&.user
    supports = assignments.select { |a| a.role == "auditor" }.map(&:user)
  
    names = []
    names << "**#{lead.first_name} #{lead.last_name}**" if lead
    names += supports.map { |s| "#{s.first_name} #{s.last_name}" }
  
    names.any? ? names.join(", ") : "Unassigned"
  end
  
end
