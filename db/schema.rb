# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 202503309183408) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_assignments", force: :cascade do |t|
    t.integer "role"
    t.integer "status"
    t.datetime "time_accepted"
    t.bigint "user_id", null: false
    t.bigint "audit_assignments_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "audit_id", null: false
    t.bigint "assigned_by"
    t.index ["audit_assignments_id"], name: "index_audit_assignments_on_audit_assignments_id"
    t.index ["audit_id"], name: "index_audit_assignments_on_audit_id"
    t.index ["user_id"], name: "index_audit_assignments_on_user_id"
  end

  create_table "audit_closure_letters", force: :cascade do |t|
    t.string "content"
    t.datetime "time_of_creation"
    t.datetime "time_of_verification"
    t.datetime "time_of_distribution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "audit_id", null: false
    t.bigint "user_id", null: false
    t.index ["audit_id"], name: "index_audit_closure_letters_on_audit_id"
    t.index ["user_id"], name: "index_audit_closure_letters_on_user_id"
  end

  create_table "audit_details", force: :cascade do |t|
    t.string "scope"
    t.string "purpose"
    t.string "objectives"
    t.string "boundaries"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "audit_id", null: false
    t.index ["audit_id"], name: "index_audit_details_on_audit_id"
  end

  create_table "audit_findings", force: :cascade do |t|
    t.string "description"
    t.integer "category"
    t.integer "risk_level"
    t.datetime "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "report_id"
    t.index ["report_id"], name: "index_audit_findings_on_report_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "log_action"
    t.datetime "timestamp"
    t.bigint "audit_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["audit_id"], name: "index_audit_logs_on_audit_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "audit_questionnaires", force: :cascade do |t|
    t.datetime "time_of_verification"
    t.datetime "time_of_distribution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "audit_id", null: false
    t.bigint "custom_questionnaire_id", null: false
    t.index ["audit_id"], name: "index_audit_questionnaires_on_audit_id"
    t.index ["custom_questionnaire_id"], name: "index_audit_questionnaires_on_custom_questionnaire_id"
  end

  create_table "audit_request_letters", force: :cascade do |t|
    t.bigint "audit_id", null: false
    t.bigint "user_id", null: false
    t.string "content"
    t.datetime "time_of_creation"
    t.datetime "time_of_verification"
    t.datetime "time_of_distribution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["audit_id"], name: "index_audit_request_letters_on_audit_id"
    t.index ["user_id"], name: "index_audit_request_letters_on_user_id"
  end

  create_table "audit_schedules", force: :cascade do |t|
    t.string "task"
    t.datetime "expected_start"
    t.datetime "expected_end"
    t.datetime "actual_start"
    t.datetime "actual_end"
    t.integer "status"
    t.bigint "audit_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["audit_id"], name: "index_audit_schedules_on_audit_id"
    t.index ["user_id"], name: "index_audit_schedules_on_user_id"
  end

  create_table "audit_standards", force: :cascade do |t|
    t.string "standard"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "audit_detail_id", null: false
    t.index ["audit_detail_id"], name: "index_audit_standards_on_audit_detail_id"
  end

  create_table "audits", force: :cascade do |t|
    t.datetime "scheduled_start_date"
    t.datetime "scheduled_end_date"
    t.datetime "actual_start_date"
    t.datetime "actual_end_date"
    t.integer "status"
    t.integer "score"
    t.integer "final_outcome"
    t.datetime "time_of_creation"
    t.datetime "time_of_verification"
    t.datetime "time_of_closure"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "company_id", null: false
    t.string "audit_type"
    t.index ["company_id"], name: "index_audits_on_company_id"
    t.index ["user_id"], name: "index_audits_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "street_name"
    t.string "city"
    t.string "postcode"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.boolean "representative_contact"
    t.string "additional_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

  create_table "corrective_actions", force: :cascade do |t|
    t.bigint "audit_id", null: false
    t.string "action_description"
    t.datetime "due_date"
    t.integer "status"
    t.datetime "time_of_creation"
    t.datetime "time_of_verification"
    t.datetime "time_of_distribution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["audit_id"], name: "index_corrective_actions_on_audit_id"
  end

  create_table "custom_questionnaires", force: :cascade do |t|
    t.string "name"
    t.datetime "time_of_creation"
    t.datetime "time_of_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_custom_questionnaires_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "document_updates", force: :cascade do |t|
    t.datetime "time_updated"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "document_id", null: false
    t.index ["document_id"], name: "index_document_updates_on_document_id"
    t.index ["user_id"], name: "index_document_updates_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "name"
    t.string "document_type"
    t.datetime "uploaded_at"
    t.string "content"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "electronic_signatures", force: :cascade do |t|
    t.datetime "signed_at"
    t.integer "signature_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "audit_id", null: false
    t.index ["audit_id"], name: "index_electronic_signatures_on_audit_id"
    t.index ["user_id"], name: "index_electronic_signatures_on_user_id"
  end

  create_table "login_attempts", force: :cascade do |t|
    t.datetime "attempt_time"
    t.boolean "success"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_login_attempts_on_user_id"
  end

  create_table "question_banks", force: :cascade do |t|
    t.string "question_text"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "response_choices_id"
    t.index ["response_choices_id"], name: "index_question_banks_on_response_choices_id"
  end

  create_table "questionnaire_sections", force: :cascade do |t|
    t.string "name"
    t.integer "section_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "custom_questionnaire_id", null: false
    t.index ["custom_questionnaire_id"], name: "index_questionnaire_sections_on_custom_questionnaire_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "status"
    t.datetime "time_of_creation"
    t.datetime "time_of_verification"
    t.datetime "time_of_distribution"
    t.bigint "audit_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["audit_id"], name: "index_reports_on_audit_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "response_choices", force: :cascade do |t|
    t.integer "response_type"
    t.string "response_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "section_questions", force: :cascade do |t|
    t.bigint "questionnaire_section_id", null: false
    t.bigint "question_bank_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_bank_id"], name: "index_section_questions_on_question_bank_id"
    t.index ["questionnaire_section_id"], name: "index_section_questions_on_questionnaire_section_id"
  end

  create_table "selected_responses", force: :cascade do |t|
    t.bigint "response_choice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["response_choice_id"], name: "index_selected_responses_on_response_choice_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "supporting_documents", force: :cascade do |t|
    t.string "name"
    t.string "content"
    t.string "location"
    t.datetime "uploaded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "audit_id", null: false
    t.bigint "user_id", null: false
    t.index ["audit_id"], name: "index_supporting_documents_on_audit_id"
    t.index ["user_id"], name: "index_supporting_documents_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts"
    t.string "unlock_token"
    t.datetime "locked_at"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendor_rpns", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "time_of_creation", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "material_criticality", null: false
    t.integer "supplier_compliance_history", null: false
    t.integer "regulatory_approvals", null: false
    t.integer "supply_chain_complexity", null: false
    t.integer "previous_supplier_performance", null: false
    t.integer "contamination_adulteration_risk", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_vendor_rpns_on_company_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_assignments", "audit_assignments", column: "audit_assignments_id"
  add_foreign_key "audit_assignments", "audits"
  add_foreign_key "audit_assignments", "users"
  add_foreign_key "audit_closure_letters", "audits"
  add_foreign_key "audit_closure_letters", "users"
  add_foreign_key "audit_details", "audits"
  add_foreign_key "audit_findings", "reports"
  add_foreign_key "audit_logs", "audits"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "audit_questionnaires", "audits"
  add_foreign_key "audit_questionnaires", "custom_questionnaires"
  add_foreign_key "audit_request_letters", "audits"
  add_foreign_key "audit_request_letters", "users"
  add_foreign_key "audit_schedules", "audits"
  add_foreign_key "audit_schedules", "users"
  add_foreign_key "audit_standards", "audit_details"
  add_foreign_key "audits", "companies"
  add_foreign_key "audits", "users"
  add_foreign_key "contacts", "companies"
  add_foreign_key "corrective_actions", "audits"
  add_foreign_key "custom_questionnaires", "users"
  add_foreign_key "document_updates", "documents"
  add_foreign_key "document_updates", "users"
  add_foreign_key "electronic_signatures", "audits"
  add_foreign_key "electronic_signatures", "users"
  add_foreign_key "login_attempts", "users"
  add_foreign_key "question_banks", "response_choices", column: "response_choices_id"
  add_foreign_key "questionnaire_sections", "custom_questionnaires"
  add_foreign_key "reports", "audits"
  add_foreign_key "reports", "users"
  add_foreign_key "section_questions", "question_banks"
  add_foreign_key "section_questions", "questionnaire_sections"
  add_foreign_key "selected_responses", "response_choices"
  add_foreign_key "supporting_documents", "audits"
  add_foreign_key "supporting_documents", "users"
  add_foreign_key "users", "companies"
  add_foreign_key "vendor_rpns", "companies"
end
