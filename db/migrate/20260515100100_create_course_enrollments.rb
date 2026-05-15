class CreateCourseEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :course_enrollments do |t|
      t.references :learner, null: false, foreign_key: true
      t.string :course_slug, null: false
      t.integer :status, null: false, default: 0
      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id
      t.string :stripe_customer_id
      t.integer :amount_cents, null: false, default: 3999
      t.string :currency, null: false, default: "eur"
      t.datetime :purchased_at
      t.datetime :completed_at
      t.string :last_lesson_key

      t.timestamps
    end

    add_index :course_enrollments, [:learner_id, :course_slug], unique: true
    add_index :course_enrollments, :stripe_checkout_session_id, unique: true
  end
end
