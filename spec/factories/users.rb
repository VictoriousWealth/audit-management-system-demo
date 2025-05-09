# spec/factories/users.rb
#Creating users of each role type for testing
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password123" }
    first_name { "Test" }
    last_name  { "User" }
    role { :auditor }

    trait :auditor do
      role { :auditor }
    end

    trait :qa_manager do
      role { :qa_manager }
    end

    trait :senior_manager do
      role { :senior_manager }
    end

    trait :sme do
      role { :sme }
    end

    trait :auditee do
      role { :auditee }
      association :company
    end
  end
end
