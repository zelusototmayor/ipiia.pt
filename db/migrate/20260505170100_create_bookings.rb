class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.string :guest_name, null: false
      t.string :guest_email, null: false
      t.string :guest_company
      t.string :topic
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :timezone, null: false, default: "Europe/Lisbon"
      t.integer :status, null: false, default: 0
      t.string :google_event_id
      t.string :google_meet_link
      t.text :notes
      t.string :confirmation_token, null: false
      t.datetime :confirmed_at
      t.datetime :cancelled_at

      t.timestamps
    end

    add_index :bookings, :starts_at
    add_index :bookings, :status
    add_index :bookings, :confirmation_token, unique: true
    add_index :bookings, :google_event_id, unique: true
  end
end
