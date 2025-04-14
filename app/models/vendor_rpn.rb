# == Schema Information
#
# Table name: vendor_rpns
#
#  id                              :bigint           not null, primary key
#  contamination_adulteration_risk :integer          not null
#  material_criticality            :integer          not null
#  previous_supplier_performance   :integer          not null
#  regulatory_approvals            :integer          not null
#  supplier_compliance_history     :integer          not null
#  supply_chain_complexity         :integer          not null
#  time_of_creation                :datetime         not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  company_id                      :bigint           not null
#
# Indexes
#
#  index_vendor_rpns_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class VendorRpn < ApplicationRecord
  belongs_to :company

  # Validations for the various risk factors
  validates :material_criticality, inclusion: { in: 1..3 }
  validates :supplier_compliance_history, inclusion: { in: 1..3 }
  validates :regulatory_approvals, inclusion: { in: 1..3 }
  validates :supply_chain_complexity, inclusion: { in: 1..3 }
  validates :previous_supplier_performance, inclusion: { in: 1..3 }
  validates :contamination_adulteration_risk, inclusion: { in: 1..3 }

  # Calculate RPN by summing up the individual risk factors
  def calculate_rpn
    total_rpn = material_criticality + supplier_compliance_history + regulatory_approvals +
               supply_chain_complexity + previous_supplier_performance + contamination_adulteration_risk
    total_rpn
  end
end
