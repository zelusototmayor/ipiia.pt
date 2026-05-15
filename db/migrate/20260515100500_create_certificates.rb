class CreateCertificates < ActiveRecord::Migration[8.0]
  def change
    create_table :certificates do |t|
      t.references :course_enrollment, null: false, foreign_key: true, index: { unique: true }
      t.string :code, null: false
      t.integer :final_score, null: false
      t.datetime :issued_at, null: false

      t.timestamps
    end

    add_index :certificates, :code, unique: true
  end
end
