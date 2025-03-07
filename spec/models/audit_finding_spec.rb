# == Schema Information
#
# Table name: audit_findings
#
#  id                   :bigint           not null, primary key
#  category             :integer
#  description          :string
#  risk_level           :integer
#  time_of_creation     :datetime
#  time_of_distribution :datetime
#  time_of_verification :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
require 'rails_helper'

RSpec.describe AuditFinding, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
