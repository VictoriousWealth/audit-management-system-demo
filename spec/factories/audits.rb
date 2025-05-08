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

# spec/factories/audits.rb
FactoryBot.define do
  factory :audit do
    association :company
    audit_type { :internal }
    status { :not_started }
    scheduled_start_date { Date.today }
    scheduled_end_date { Date.today + 1.day }
    time_of_creation { Time.current }
    user { nil }

    trait :internal do
      audit_type { :internal }
    end

    trait :external do
      audit_type { :external }
    end

    trait :not_started do
      status { :not_started }
    end

    trait :in_progress do
      status { :in_progress }
      actual_start_date { Time.current }
    end

    trait :pending_review do
      status { :pending_review }
      actual_start_date { Time.current - 2.days }
      actual_end_date   { Time.current - 1.day }
    end

    trait :completed do
      status { :completed }
      actual_start_date { Time.current - 3.days }
      actual_end_date   { Time.current - 1.day }
      time_of_closure   { Time.current }
    end

    trait :cancelled do
      status { :cancelled }
      actual_start_date { Time.current - 1.day }
      actual_end_date   { Time.current }
    end

    trait :pass do
      final_outcome { :pass }
    end

    trait :fail do
      final_outcome { :fail }
    end

    trait :with_detail do
      after(:create) do |audit|
        create(:audit_detail, audit: audit)
      end
    end

    trait :with_detail_and_standards do
      after(:create) do |audit|
        create(:audit_detail, :with_standards, audit: audit)
      end
    end
    
    transient do
      lead_user    { create(:user, :auditor) }
      auditee_user { create(:user, :auditee) }
      assigner     { create(:user, :qa_manager) }
    end

    # === Base: Lead + Auditee only ===
    trait :with_lead_and_auditee do
      after(:create) do |audit, evaluator|
        create(:audit_assignment, :lead_auditor, :assigned, audit: audit, user: evaluator.lead_user, assigner: evaluator.assigner)
        create(:audit_assignment, :auditee, :assigned, audit: audit, user: evaluator.auditee_user, assigner: evaluator.assigner)
      end
    end

    # === Lead + Auditee only (no extra roles)
    trait :basic_team do
      with_lead_and_auditee
    end

    # === Lead + Auditee + Auditor + SME (SME role)
    trait :with_auditor_and_sme_sme do
      transient do
        auditor_user { create(:user, :auditor) }
        sme_user     { create(:user, :sme) }
      end

      after(:create) do |audit, evaluator|
        create(:audit_assignment, :lead_auditor, :assigned, audit: audit, user: evaluator.lead_user, assigner: evaluator.assigner)
        create(:audit_assignment, :auditee, :assigned, audit: audit, user: evaluator.auditee_user, assigner: evaluator.assigner)
        create(:audit_assignment, :auditor, :assigned, audit: audit, user: evaluator.auditor_user, assigner: evaluator.assigner)
        create(:audit_assignment, :sme, :assigned, audit: audit, user: evaluator.sme_user, assigner: evaluator.assigner)
      end
    end

    # === Lead + Auditee + Auditor + SME (who is user with AUDITOR role)
    trait :with_auditor_and_sme_auditor_user do
      transient do
        auditor_user { create(:user, :auditor) }
        sme_user     { create(:user, :auditor) }  # still role :auditor
      end

      after(:create) do |audit, evaluator|
        create(:audit_assignment, :lead_auditor, :assigned, audit: audit, user: evaluator.lead_user, assigner: evaluator.assigner)
        create(:audit_assignment, :auditee, :assigned, audit: audit, user: evaluator.auditee_user, assigner: evaluator.assigner)
        create(:audit_assignment, :auditor, :assigned, audit: audit, user: evaluator.auditor_user, assigner: evaluator.assigner)
        create(:audit_assignment, :sme, :assigned, audit: audit, user: evaluator.sme_user, assigner: evaluator.assigner)
      end
    end
  end
end
