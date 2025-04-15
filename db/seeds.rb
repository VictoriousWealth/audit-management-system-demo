# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# db/seeds.rb
#Auditor
User.where(email: 'bob@sheffield.ac.uk').first_or_create(
  first_name: 'Bob',
  last_name: 'Dylan',
  role: 0,
  password: 'Password1234',
  password_confirmation: 'Password1234'
)

#Auditee
User.where(email: 'alex@sheffield.ac.uk').first_or_create(
  first_name: 'Alex',
  last_name: 'Turner',
  role: 1,
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

User.where(email: 'LYBE2004@hotmail.com').first_or_create(
  first_name: 'Leroy',
  last_name: 'Barnie',
  role: 3,
  password: 'Password1234',
  password_confirmation: 'Password1234'
)

puts "Users created or found successfully!"

Audit.create!(
  scheduled_start_date: DateTime.new(2025, 4, 10, 9, 0, 0),
  scheduled_end_date:   DateTime.new(2025, 4, 10, 17, 0, 0),
  actual_start_date:    nil,  # Audit hasn't started yet
  actual_end_date:      nil,  # Audit hasn't ended yet
  status:               0,    # Set an appropriate status (e.g., 0 for scheduled)
  score:                nil,  # No score yet
  final_outcome:        nil,  # No final outcome yet
  time_of_creation:     DateTime.now,
  time_of_verification: nil,  # Not verified yet
  time_of_closure:      nil,  # Not closed yet
  user_id:              auditor = User.find_by(email: 'bob@sheffield.ac.uk').id,
  company_id:           1,    # Adjust to an existing company id in your DB
  audit_type:           "internal"  # or any other type as appropriate
)


puts "Audit created successfully!"
