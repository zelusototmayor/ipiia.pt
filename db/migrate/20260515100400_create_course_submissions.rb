class CreateCourseSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :course_submissions do |t|
      t.references :course_enrollment, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.text :workflow_text, null: false
      t.integer :ai_score
      t.text :ai_feedback_json
      t.string :ai_provider
      t.datetime :evaluated_at

      t.timestamps
    end

    add_index :course_submissions, [:course_enrollment_id, :created_at]
  end
end
