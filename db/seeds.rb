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