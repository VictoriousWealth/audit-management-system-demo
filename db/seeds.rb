puts "🏢 Seeding Companies & VendorRPNs..."

30.times do
  company = Company.create!(
    name: Faker::Company.name,
    street_name: Faker::Address.street_name,
    city: Faker::Address.city,
    postcode: Faker::Address.postcode
  )

  rand(2..15).times do
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
end

puts "✅ Created 30 companies with VendorRPNs"




puts "👥 Seeding Users..."

qa_manager = User.find_or_create_by!(email: "nina@sheffield.ac.uk") do |u|
  u.first_name = "Nina"
  u.last_name = "Simone"
  u.role = :qa_manager
  u.password = "Password1234"
end

senior_manager = User.find_or_create_by!(email: "jane@sheffield.ac.uk") do |u|
  u.first_name = "Jane"
  u.last_name = "Doe"
  u.role = :senior_manager
  u.password = "Password1234"
end

auditor = User.find_or_create_by!(email: "bob@sheffield.ac.uk") do |u|
  u.first_name = "Bob"
  u.last_name = "Dylan"
  u.role = :auditor
  u.password = "Password1234"
end

sme = User.find_or_create_by!(email: "mark@sheffield.ac.uk") do |u|
  u.first_name = "Mark"
  u.last_name = "Gordon"
  u.role = :sme
  u.password = "Password1234"
end

# Auditee linked to first company
first_company = Company.first
auditee = User.find_or_create_by!(email: "alex@sheffield.ac.uk") do |u|
  u.first_name = "Alex"
  u.last_name = "Turner"
  u.role = :auditee
  u.company = first_company
  u.password = "Password1234"
end

puts "✅ Key users created"




puts "📋 Seeding Question Bank and Questionnaire..."

# Ensure at least one QA Manager exists
qa_manager = User.find_or_create_by!(email: "nina@sheffield.ac.uk") do |u|
  u.first_name = "Nina"
  u.last_name = "Simone"
  u.role = :qa_manager
  u.password = "Password1234"
  u.password_confirmation = "Password1234"
end

# Questions to seed
questions = [
  { question_text: "Are you licensed by the MHRA or equivalent?", category: "Registration" },
  { question_text: "Give details of other company quality systems (e.g. ISO 9000).", category: "Registration" },
  { question_text: "Please give details of staff training programme.", category: "Registration" },
  { question_text: "Will you supply an original Certificate of Analysis for each batch?", category: "Certificate of Analysis" },
  { question_text: "What formal policy do you have for complaints?", category: "Complaints/Customer Relations" }
]

# Seed QuestionBank
questions.each do |q|
  QuestionBank.find_or_create_by!(question_text: q[:question_text]) do |qb|
    qb.category = q[:category]
  end
end

# Create Custom Questionnaire linked to QA Manager
questionnaire = CustomQuestionnaire.find_or_create_by!(name: "YCD - Supplier Approval Guidance Pre Qualification Questionnaire") do |cq|
  cq.time_of_creation = Time.now
  cq.user = qa_manager
end

# Create Sections
section_1 = QuestionnaireSection.find_or_create_by!(name: "Section 1", custom_questionnaire: questionnaire) do |s|
  s.section_order = 1
end

# Link questions to Section 1
questions.each do |q|
  qb = QuestionBank.find_by!(question_text: q[:question_text])
  SectionQuestion.find_or_create_by!(question_bank: qb, questionnaire_section: section_1)
end

puts "✅ Question Bank, Questionnaire, and Sections seeded successfully!"











