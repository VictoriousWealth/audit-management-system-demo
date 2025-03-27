# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# user = User.create(
#   email: "test@email.com"
#   password: "Test1234"

# company = Company.create(
#   name: "Company 1",
#   street_name: "1 Street Name",
#   postcode: "S1 1ST",
#   city: "Sheffield"
# )

# audit = Audit.create(
#   id: 1,
#   company_id: 1,
#   user_id: 1,
#   scheduled_start_date: "2025-03-20",
#   scheduled_end_date: "2025-03-20",
#   actual_start_date: "2025-03-20",
#   actual_end_date: "2025-03-20",
#   status: 0,
#   final_outcome: 0,
#   score: 0,
#   time_of_creation: "2025-03-20",
#   time_of_verification: "2025-03-20",
#   time_of_closure: "2025-03-20"
# )

# audit_details = AuditDetail.create(
#   audit_id: 1,
#   scope: "This is the scope of the audit which will be filled from the audit once it is implemented",
#   purpose: "This is the purpose of the audit which will be filled from the audit once it is implemented",
#   objectives: "This is the objective of the audit which will be filled from the audit once it is implemented",
#   boundaries: "This is the boundaries of the audit which will be filled from the audit once it is implemented"
# )


audit_assignment1 = AuditAssignment.create(
  audit_id: 1,
  user_id: 2,
  role: 1,
  status: 0,
  time_accepted: "2025-03-20"
)
audit_assignment2 = AuditAssignment.create(
  audit_id: 1,
  user_id: 3,
  role: 1,
  status: 0,
  time_accepted: "2025-03-20"
)
audit_assignment3 = AuditAssignment.create(
  audit_id: 1,
  user_id: 4,
  role: 0,
  status: 0,
  time_accepted: "2025-03-20"
)