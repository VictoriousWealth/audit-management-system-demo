# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# db/seeds.rb

require 'faker'

# Clear existing data (only in development/testing!)
AuditStandard.destroy_all
AuditAssignment.destroy_all
AuditDetail.destroy_all
AuditFinding.destroy_all
Report.destroy_all
Audit.destroy_all
VendorRpn.destroy_all
User.destroy_all
Company.destroy_all









# === 1. Create Companies ===
companies = 30.times.map do
  company = Company.create!(
    name: Faker::Company.name,
    street_name: Faker::Address.street_name,
    city: Faker::Address.city,
    postcode: Faker::Address.postcode
  )

  rand(2..5).times do
    company.vendor_rpns.create!(
      material_criticality: rand(1..3),
      supplier_compliance_history: rand(1..3),
      regulatory_approvals: rand(1..3),
      supply_chain_complexity: rand(1..3),
      previous_supplier_performance: rand(1..3),
      contamination_adulteration_risk: rand(1..3),
      time_of_creation: Faker::Date.backward(days: 365)
    )
  end

  puts "📦 Created #{company.vendor_rpns.count} VendorRPN(s) for #{company.name}"
  company
end



# === 2. Create Users ===

# Auditees (must belong to a company)
auditees = 70.times.map do
  company = companies.sample
  user = User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    role: :auditee,
    company: company,
    password: "password123",
    password_confirmation: "password123"
  )
  puts "✅ Auditee ##{user.id} with name: #{user.full_name} from company #{company.name} created!"
  user
end

# Auditors
auditors = 25.times.map do
  user = User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    role: :auditor,
    password: "password123",
    password_confirmation: "password123"
  )
  puts "✅ Auditor ##{user.id} with name: #{user.full_name} created!"
  user
end

# SMEs
smes = 15.times.map do
  user = User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    role: :sme,
    password: "password123",
    password_confirmation: "password123"
  )
  puts "✅ SME ##{user.id} with name: #{user.full_name} created!"
  user
end

# QAs
qas = 5.times.map do
  user = User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    role: 2,
    password: "password123",
    password_confirmation: "password123"
  )
  puts "✅ QA ##{user.id} with name: #{user.full_name} created!"
  user
end

# Eligible assignable users (lead/sme/support)
eligible_assigners = auditors + smes
#Eligible assigned by
assigners = qas

# === 3. Create Not Started Audits ===

30.times do
  local_assigners = eligible_assigners.dup
  auditee = auditees.sample
  company = auditee.company

  start_date = Faker::Date.forward(days: 10)
  end_date = start_date + rand(3..7).days

  audit = Audit.create!(
    company_id: company.id,
    audit_type: %w[internal external].sample,
    scheduled_start_date: start_date,
    scheduled_end_date: end_date,
    actual_start_date: nil,
    actual_end_date: nil,
    status: :not_started,
    time_of_creation: Time.current
  )

  # === AuditDetail ===
  detail = AuditDetail.create!(
    audit: audit,
    scope: Faker::Company.bs.titleize,
    objectives: Faker::Lorem.sentence(word_count: 8),
    purpose: Faker::Lorem.sentence(word_count: 6),
    boundaries: Faker::Lorem.paragraph(sentence_count: 2)
  )

  # === AuditStandards ===
  ["ISO 9001", "GMP", "MHRA"].sample(2).each do |std|
    detail.audit_standards.create!(standard: std)
  end

  # === AuditAssignments ===

  # Lead Auditor
  lead = auditors.sample
  audit.audit_assignments.create!(
    user_id: lead.id,
    role: :lead_auditor,
    status: :assigned,
    assigned_by: qas.sample.id

  )
  local_assigners -= [lead]

  # Auditee
  audit.audit_assignments.create!(
    user_id: auditee.id,
    role: :auditee,
    status: :assigned,
    assigned_by: qas.sample.id

  )

  # Support Auditors
  (auditors - [lead]).sample(2).each do |support|
    audit.audit_assignments.create!(
      user_id: support.id,
      role: :auditor,
      status: :assigned,
      assigned_by: qas.sample.id

    )
    local_assigners -= [support]
  end

  # SMEs (can be either auditors or smes users)
  local_assigners.sample(2).each do |sme|
    audit.audit_assignments.create!(
      user_id: sme.id,
      role: :sme,
      status: :assigned,
      assigned_by: qas.sample.id
    )
  end

  puts "✅ Created Not-Started Audit ##{audit.id} (#{audit.audit_type}) for #{company.name} with lead auditor #{lead.full_name}"
end















# === 4. Create In-Progress Audits ===
# Late ones --- TO BE CHANGED as it is only a mock of a mockery
11.times do
  local_assigners = eligible_assigners.dup
  auditee = auditees.sample
  company = auditee.company

  # Dates
  start_date = Faker::Date.backward(days: 30)
  end_date = Faker::Date.forward(days: 15)
  actual_start = start_date + rand(1..5).days

  audit = Audit.create!(
    company_id: company.id,
    audit_type: %w[internal external].sample,
    scheduled_start_date: start_date,
    scheduled_end_date: end_date,
    actual_start_date: actual_start,
    actual_end_date: nil,
    status: :in_progress,
    score: rand(0..100),
    time_of_creation: Faker::Date.backward(days: 60)
  )

  detail = AuditDetail.create!(
    audit: audit,
    scope: Faker::Company.bs.titleize,
    objectives: Faker::Lorem.sentence(word_count: 8),
    purpose: Faker::Lorem.sentence(word_count: 6),
    boundaries: Faker::Lorem.paragraph(sentence_count: 2)
  )

  ["ISO 9001", "GMP", "MHRA"].sample(2).each do |std|
    detail.audit_standards.create!(standard: std)
  end

  # === Assignments ===
  lead = auditors.sample
  audit.audit_assignments.create!(user_id: lead.id, role: :lead_auditor, status: :assigned, assigned_by: qas.sample.id)
  local_assigners -= [lead]

  audit.audit_assignments.create!(user_id: auditee.id, role: :auditee, status: :assigned, assigned_by: qas.sample.id)

  (auditors - [lead]).sample(2).each do |support|
    audit.audit_assignments.create!(user_id: support.id, role: :auditor, status: :assigned, assigned_by: qas.sample.id)
    local_assigners -= [support]
  end

  local_assigners.sample(2).each do |sme|
    audit.audit_assignments.create!(user_id: sme.id, role: :sme, status: :assigned, assigned_by: qas.sample.id)
  end

  puts "🟡 Created In-Progress Audit ##{audit.id} with score #{audit.score} for #{company.name} with lead auditor #{lead.full_name}"
end

# On time ones --- TO BE CHANGED as it is only a mock of a mockery
17.times do
  local_assigners = eligible_assigners.dup
  auditee = auditees.sample
  company = auditee.company

  # Dates
  start_date = Faker::Date.backward(days: 30)
  end_date = Faker::Date.forward(days: 15)
  actual_start = start_date - rand(1..5).days

  audit = Audit.create!(
    company_id: company.id,
    audit_type: %w[internal external].sample,
    scheduled_start_date: start_date,
    scheduled_end_date: end_date,
    actual_start_date: actual_start,
    actual_end_date: nil,
    status: :in_progress,
    score: rand(0..100),
    time_of_creation: Faker::Date.backward(days: 60)
  )

  detail = AuditDetail.create!(
    audit: audit,
    scope: Faker::Company.bs.titleize,
    objectives: Faker::Lorem.sentence(word_count: 8),
    purpose: Faker::Lorem.sentence(word_count: 6),
    boundaries: Faker::Lorem.paragraph(sentence_count: 2)
  )

  ["ISO 9001", "GMP", "MHRA"].sample(2).each do |std|
    detail.audit_standards.create!(standard: std)
  end

  # === Assignments ===
  lead = auditors.sample
  audit.audit_assignments.create!(user_id: lead.id, role: :lead_auditor, status: :assigned, assigned_by: qas.sample.id)
  local_assigners -= [lead]

  audit.audit_assignments.create!(user_id: auditee.id, role: :auditee, status: :assigned, assigned_by: qas.sample.id)

  (auditors - [lead]).sample(2).each do |support|
    audit.audit_assignments.create!(user_id: support.id, role: :auditor, status: :assigned, assigned_by: qas.sample.id)
    local_assigners -= [support]
  end

  local_assigners.sample(2).each do |sme|
    audit.audit_assignments.create!(user_id: sme.id, role: :sme, status: :assigned, assigned_by: qas.sample.id)
  end

  puts "🟡 Created In-Progress Audit ##{audit.id} with score #{audit.score} for #{company.name} with lead auditor #{lead.full_name}"
end


















# === 5. Create Completed Audits ===

20.times do
  local_assigners = eligible_assigners.dup
  auditee = auditees.sample
  company = auditee.company

  scheduled_start = Faker::Date.backward(days: 90)
  actual_start = scheduled_start + rand(1..5).days
  actual_end = actual_start + rand(2..7).days
  score = rand(0..100)
  outcome = score > 50 ? :pass : :fail

  audit = Audit.create!(
    company_id: company.id,
    audit_type: %w[internal external].sample,
    scheduled_start_date: scheduled_start,
    scheduled_end_date: actual_end + rand(1..5).days,
    actual_start_date: actual_start,
    actual_end_date: actual_end,
    score: score,
    final_outcome: Audit.final_outcomes[outcome],
    status: :completed,
    time_of_creation: Faker::Date.backward(days: 100)
  )

  # === AuditDetail ===
  detail = AuditDetail.create!(
    audit: audit,
    scope: Faker::Company.bs.titleize,
    objectives: Faker::Lorem.sentence(word_count: 8),
    purpose: Faker::Lorem.sentence(word_count: 6),
    boundaries: Faker::Lorem.paragraph(sentence_count: 2)
  )

  ["ISO 9001", "GMP", "MHRA"].sample(2).each do |std|
    detail.audit_standards.create!(standard: std)
  end

  # === AuditAssignments ===
  lead = auditors.sample
  audit.audit_assignments.create!(user_id: lead.id, role: :lead_auditor, status: :assigned, assigned_by: qas.sample.id)
  local_assigners -= [lead]

  audit.audit_assignments.create!(user_id: auditee.id, role: :auditee, status: :assigned, assigned_by: qas.sample.id)

  (auditors - [lead]).sample(2).each do |support|
    audit.audit_assignments.create!(user_id: support.id, role: :auditor, status: :assigned, assigned_by: qas.sample.id)
    local_assigners -= [support]
  end

  local_assigners.sample(2).each do |sme|
    audit.audit_assignments.create!(user_id: sme.id, role: :sme, status: :assigned, assigned_by: qas.sample.id)
  end

  # === Report ===
  report = audit.reports.create!(
    status: %i[generated sent].sample,
    time_of_creation: actual_end,
    time_of_verification: actual_end + 1.day,
    time_of_distribution: actual_end + 2.days,
    user_id: lead.id
  )

  # === Audit Findings ===
  (100-score).times do
    report.audit_findings.create!(
      description: Faker::Lorem.sentence(word_count: 6),
      category: rand(0..2),
      risk_level: rand(0..2),
      due_date: Faker::Date.forward(days: 30)
    )
  end

  puts "✅ Completed Audit ##{audit.id} (#{outcome.to_s.upcase}) – Score: #{score}, Findings: #{report.audit_findings.count}"
end













#Auditor
User.where(email: 'bob@sheffield.ac.uk').first_or_create(
  first_name: 'Bob',
  last_name: 'Dylan',
  role: 0,
  password: 'Password1234',
  password_confirmation: 'Password1234'
)

#Auditee
company = Company.first
User.where(email: 'alex@sheffield.ac.uk').first_or_create(
  first_name: 'Alex',
  last_name: 'Turner',
  role: 1,
  company: company,
  password: 'Password1234',
  password_confirmation: 'Password1234'
)

#QA
User.where(email: 'nina@sheffield.ac.uk').first_or_create(
  first_name: 'Nina',
  last_name: 'Simone',
  role: 2,
  password: 'Password1234',
  password_confirmation: 'Password1234'
)

#Senior Manager
User.where(email: 'jane@sheffield.ac.uk').first_or_create(
  first_name: 'Jane',
  last_name: 'Doe',
  role: 3,
  password: 'Password1234',
  password_confirmation: 'Password1234'
)

#Senior Manager
User.where(email: 'LYBE2004@hotmail.com').first_or_create(
  first_name: 'Leroy',
  last_name: 'Barnie',
  role: 3,
  password: 'Password1234',
  password_confirmation: 'Password1234'
)

puts "✅ Users created or found successfully!"















puts "✅ Seeding completed! 🎉"
puts "🔍 Companies: #{Company.count}"
puts "👥 Users: #{User.count}"
puts "📋 Audits: #{Audit.count} (#{Audit.where(status: :not_started).count} not started, #{Audit.where(status: :in_progress).count} in progress, #{Audit.where(status: :completed).count} completed)"
puts "🧾 Reports: #{Report.count}"
puts "📍 Findings: #{AuditFinding.count}"
puts "📦 VendorRPNs: #{VendorRpn.count}"
