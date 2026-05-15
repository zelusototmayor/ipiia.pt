class CreateLessonProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :lesson_progresses do |t|
      t.references :course_enrollment, null: false, foreign_key: true
      t.string :lesson_key, null: false
      t.text :exercise_response
      t.datetime :completed_at

      t.timestamps
    end

    add_index :lesson_progresses, [:course_enrollment_id, :lesson_key], unique: true
  end
end
