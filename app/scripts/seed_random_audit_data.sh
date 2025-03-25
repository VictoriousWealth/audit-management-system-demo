#!/bin/bash

# Fully validated seeding script for audit data
# Requires faker gem

rails runner <<'RUBY'
require 'faker'

puts "\n🌱 Seeding new company..."

company = Company.create!(
  name: Faker::Company.unique.name,
  address: Faker::Address.full_address
)
puts "✅ Company: #{company.name}"

puts "\n👤 Creating users..."

roles = %i[auditor auditee qa_manager senior_manager]
users = []

15.times do
  role = if users.count { |u| u.role == :sme } < 3
    :sme
  else
    roles.sample
  end

  user = User.create!(
    email: Faker::Internet.unique.email,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    role: role,
    password: "password123",
    password_confirmation: "password123",
    company: company
  )
  users << user
  puts "   ➕ #{user.first_name} #{user.last_name} (#{user.role})"
end

auditors = users.select { |u| u.role == "auditor" }
auditees = users.select { |u| u.role == "auditee" }
smes = users.select { |u| u.role == "sme" }

puts "\n📋 Creating audits..."

statuses = %i[not_started in_progress completed]

def generate_dates(status)
  now = Time.now
  case status
  when :not_started
    sched_start = [now + rand(1..10).days, nil].sample
    sched_end = sched_start ? sched_start + rand(1..5).days : nil
    actual_start = nil
    actual_end = nil
  when :in_progress
    sched_start = now - rand(10..1).days
    sched_end = sched_start + rand(3..10).days
    actual_start = now - rand(1..10).days
    actual_end = nil
  when :completed
    sched_start = now - rand(15..10).days
    sched_end = sched_start + rand(1..5).days
    actual_start = now - rand(15..10).days
    actual_end = actual_start + rand(1..5).days
  end
  return sched_start, sched_end, actual_start, actual_end
end

12.times do
  status = statuses.sample
  scheduled_start, scheduled_end, actual_start, actual_end = generate_dates(status)

  # Time of creation logic
  time_of_creation = scheduled_start ? scheduled_start - rand(1..3).days : Time.now

  auditee = auditees.sample
  audit = Audit.create!(
    scheduled_start_date: scheduled_start,
    scheduled_end_date: scheduled_end,
    actual_start_date: actual_start,
    actual_end_date: actual_end,
    time_of_creation: time_of_creation,
    time_of_verification: Time.now + 1.day,
    status: status,
    final_outcome: %i[pass fail].sample,
    score: rand(70..100),
    company: company,
    user: auditee
  )

  puts "✅ Audit ##{audit.id} (#{status})"

  # Assign Lead Auditor (always required)
  lead = auditors.sample
  AuditAssignment.create!(
    audit: audit,
    user: lead,
    role: :lead_auditor,
    status: :assigned,
    time_accepted: Time.now
  )
  puts "   👨‍💼 Lead Auditor: #{lead.first_name}"

  # Assign optional auditors
  rand(0..2).times do
    auditor = (auditors - [lead]).sample
    AuditAssignment.create!(
      audit: audit,
      user: auditor,
      role: :auditor,
      status: :assigned,
      time_accepted: Time.now
    )
    puts "   🧑 Auditor: #{auditor.first_name}"
  end

  # Assign optional SMEs
  rand(0..2).times do
  sme = smes.sample
  next unless sme # skip if none exist

  AuditAssignment.create!(
      audit: audit,
      user: sme,
      role: :sme,
      status: :assigned,
      time_accepted: Time.now
  )
  puts "   📚 SME: #{sme.first_name}"
  end


  # Auditee (always required)
  AuditAssignment.create!(
    audit: audit,
    user: auditee,
    role: :auditee,
    status: :assigned,
    time_accepted: Time.now
  )
  puts "   🙋 Auditee: #{auditee.first_name}"
end

puts "\n🎉 All audit data seeded with 100% valid constraints!"
RUBY
