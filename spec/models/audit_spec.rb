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
require 'rails_helper'

RSpec.describe Audit, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
