# == Schema Information
#
# Table name: audit_assignments
#
#  id            :bigint           not null, primary key
#  assigned_by   :bigint
#  role          :integer
#  status        :integer
#  time_accepted :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  audit_id      :bigint           not null
#  user_id       :bigint           not null
#

FactoryBot.define do
  factory :audit_assignment do
    association :audit
    association :user
    association :assigner, factory: :user  # maps to `assigned_by`

    role { :auditor }
    status { :assigned }
    time_accepted { nil }

    trait :lead_auditor do
      role { :lead_auditor }
    end

    trait :supporting_auditor do
      role { :auditor }
    end

    trait :sme do
      role { :sme }
    end

    trait :auditee do
      role { :auditee }
    end

    trait :accepted do
      status { :accepted }
      time_accepted { Time.current }
    end

    trait :declined do
      status { :declined }
    end

    
  end
end
