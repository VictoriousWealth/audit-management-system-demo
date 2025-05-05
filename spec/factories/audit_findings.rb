# == Schema Information
#
# Table name: audit_findings
#
#  id          :bigint           not null, primary key
#  category    :integer
#  description :string
#  due_date    :datetime
#  risk_level  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  report_id   :bigint
#
# Indexes
#
#  index_audit_findings_on_report_id  (report_id)
#
# Foreign Keys
#
#  fk_rails_...  (report_id => reports.id)
#
FactoryBot.define do
  factory :audit_finding do
    description { "MyString" }
    category { 1 }
    risk_level { 1 }
    due_date { "2025-03-12 17:16:44" }
  end
end
