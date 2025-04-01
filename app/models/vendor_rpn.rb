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
