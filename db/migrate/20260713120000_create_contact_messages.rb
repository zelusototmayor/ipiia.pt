class CreateContactMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_messages do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :company
      t.string :role
      t.text :message

      t.timestamps
    end

    add_index :contact_messages, :email
  end
end
