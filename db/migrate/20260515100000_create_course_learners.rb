class CreateCourseLearners < ActiveRecord::Migration[8.0]
  def change
    create_table :learners do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :company
      t.string :role
      t.string :stripe_customer_id

      t.timestamps
    end

    add_index :learners, :email, unique: true
    add_index :learners, :stripe_customer_id
  end
end
