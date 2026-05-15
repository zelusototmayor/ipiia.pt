class CreateAiAssessments < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_assessments do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :role
      t.string :company
      t.text :use_case
      t.text :answers_json, null: false
      t.text :dimension_scores_json, null: false
      t.text :signals_json, null: false
      t.text :priorities_json, null: false
      t.text :strengths_json, null: false
      t.integer :overall_score, null: false
      t.string :profile_key, null: false
      t.string :profile_title, null: false
      t.text :profile_summary, null: false
      t.string :recommended_path, null: false

      t.timestamps
    end

    add_index :ai_assessments, :email
    add_index :ai_assessments, :profile_key
  end
end
