# == Schema Information
#
# Table name: audit_questionnaires
#
#  id                      :bigint           not null, primary key
#  time_of_distribution    :datetime
#  time_of_verification    :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  audit_id                :bigint           not null
#  custom_questionnaire_id :bigint           not null
#
# Indexes
#
#  index_audit_questionnaires_on_audit_id                 (audit_id)
#  index_audit_questionnaires_on_custom_questionnaire_id  (custom_questionnaire_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (custom_questionnaire_id => custom_questionnaires.id)
#
class AuditQuestionnaire < ApplicationRecord
  belongs_to :custom_questionnaire, optional: true
  belongs_to :audit, optional: true
end
