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

ActiveRecord::Schema[8.0].define(version: 2026_05_15_100500) do
  create_table "ai_assessments", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role"
    t.string "company"
    t.text "use_case"
    t.text "answers_json", null: false
    t.text "dimension_scores_json", null: false
    t.text "signals_json", null: false
    t.text "priorities_json", null: false
    t.text "strengths_json", null: false
    t.integer "overall_score", null: false
    t.string "profile_key", null: false
    t.string "profile_title", null: false
    t.text "profile_summary", null: false
    t.string "recommended_path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_ai_assessments_on_email"
    t.index ["profile_key"], name: "index_ai_assessments_on_profile_key"
  end

  create_table "bookings", force: :cascade do |t|
    t.string "guest_name", null: false
    t.string "guest_email", null: false
    t.string "guest_company"
    t.string "topic"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "timezone", default: "Europe/Lisbon", null: false
    t.integer "status", default: 0, null: false
    t.string "google_event_id"
    t.string "google_meet_link"
    t.text "notes"
    t.string "confirmation_token", null: false
    t.datetime "confirmed_at"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_bookings_on_confirmation_token", unique: true
    t.index ["google_event_id"], name: "index_bookings_on_google_event_id", unique: true
    t.index ["starts_at"], name: "index_bookings_on_starts_at"
    t.index ["status"], name: "index_bookings_on_status"
  end

  create_table "certificates", force: :cascade do |t|
    t.integer "course_enrollment_id", null: false
    t.string "code", null: false
    t.integer "final_score", null: false
    t.datetime "issued_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_certificates_on_code", unique: true
    t.index ["course_enrollment_id"], name: "index_certificates_on_course_enrollment_id", unique: true
  end

  create_table "course_enrollments", force: :cascade do |t|
    t.integer "learner_id", null: false
    t.string "course_slug", null: false
    t.integer "status", default: 0, null: false
    t.string "stripe_checkout_session_id"
    t.string "stripe_payment_intent_id"
    t.string "stripe_customer_id"
    t.integer "amount_cents", default: 3999, null: false
    t.string "currency", default: "eur", null: false
    t.datetime "purchased_at"
    t.datetime "completed_at"
    t.string "last_lesson_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["learner_id", "course_slug"], name: "index_course_enrollments_on_learner_id_and_course_slug", unique: true
    t.index ["learner_id"], name: "index_course_enrollments_on_learner_id"
    t.index ["stripe_checkout_session_id"], name: "index_course_enrollments_on_stripe_checkout_session_id", unique: true
  end

  create_table "course_submissions", force: :cascade do |t|
    t.integer "course_enrollment_id", null: false
    t.string "status", default: "pending", null: false
    t.text "workflow_text", null: false
    t.integer "ai_score"
    t.text "ai_feedback_json"
    t.string "ai_provider"
    t.datetime "evaluated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_enrollment_id", "created_at"], name: "idx_on_course_enrollment_id_created_at_bea1c383ff"
    t.index ["course_enrollment_id"], name: "index_course_submissions_on_course_enrollment_id"
  end

  create_table "learners", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "company"
    t.string "role"
    t.string "stripe_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_learners_on_email", unique: true
    t.index ["stripe_customer_id"], name: "index_learners_on_stripe_customer_id"
  end

  create_table "lesson_progresses", force: :cascade do |t|
    t.integer "course_enrollment_id", null: false
    t.string "lesson_key", null: false
    t.text "exercise_response"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_enrollment_id", "lesson_key"], name: "index_lesson_progresses_on_course_enrollment_id_and_lesson_key", unique: true
    t.index ["course_enrollment_id"], name: "index_lesson_progresses_on_course_enrollment_id"
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.integer "course_enrollment_id", null: false
    t.text "answers_json", null: false
    t.integer "score", null: false
    t.integer "correct_count", null: false
    t.integer "question_count", null: false
    t.boolean "passed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_enrollment_id", "created_at"], name: "index_quiz_attempts_on_course_enrollment_id_and_created_at"
    t.index ["course_enrollment_id"], name: "index_quiz_attempts_on_course_enrollment_id"
  end

  add_foreign_key "certificates", "course_enrollments"
  add_foreign_key "course_enrollments", "learners"
  add_foreign_key "course_submissions", "course_enrollments"
  add_foreign_key "lesson_progresses", "course_enrollments"
  add_foreign_key "quiz_attempts", "course_enrollments"
end
