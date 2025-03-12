# == Schema Information
#
# Table name: audit_assignments
#
#  id            :bigint           not null, primary key
#  role          :integer
#  status        :integer
#  time_accepted :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe AuditAssignment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
