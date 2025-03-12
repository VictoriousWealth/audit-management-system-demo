# == Schema Information
#
# Table name: login_attempts
#
#  id           :bigint           not null, primary key
#  attempt_time :datetime
#  ip_address   :string
#  success      :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_login_attempts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe LoginAttempt, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
