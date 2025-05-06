# == Schema Information
#
# Table name: audit_closure_letters
#
#  id                   :bigint           not null, primary key
#  content              :string
#  time_of_creation     :datetime
#  time_of_distribution :datetime
#  time_of_verification :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  audit_id             :bigint           not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_audit_closure_letters_on_audit_id  (audit_id)
#  index_audit_closure_letters_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (audit_id => audits.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :audit_closure_letter do
    content { { company: {name: "Test Company"}, notes: { summary_statement: "Test summary", overall_compliance: "Compliant" } }.to_json }
    time_of_creation { "2025-03-12 17:03:48" }
    time_of_verification { "2025-03-12 17:03:48" }
    time_of_distribution { "2025-03-12 17:03:48" }
  end
end
