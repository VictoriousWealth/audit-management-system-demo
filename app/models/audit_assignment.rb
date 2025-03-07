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
class AuditAssignment < ApplicationRecord
end
