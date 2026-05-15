class CreateQuizAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_attempts do |t|
      t.references :course_enrollment, null: false, foreign_key: true
      t.text :answers_json, null: false
      t.integer :score, null: false
      t.integer :correct_count, null: false
      t.integer :question_count, null: false
      t.boolean :passed, null: false, default: false

      t.timestamps
    end

    add_index :quiz_attempts, [:course_enrollment_id, :created_at]
  end
end
