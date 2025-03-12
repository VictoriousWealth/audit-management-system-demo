# == Schema Information
#
# Table name: document_updates
#
#  id           :bigint           not null, primary key
#  time_updated :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  document_id  :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_document_updates_on_document_id  (document_id)
#  index_document_updates_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :document_update do
    time_updated { "2025-03-12 16:27:13" }
    user { nil }
  end
end
