class CreateCourseWaitlistEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :course_waitlist_entries do |t|
      t.string :name
      t.string :email, null: false
      t.string :course_slug, null: false

      t.timestamps
    end

    add_index :course_waitlist_entries, [ :email, :course_slug ], unique: true
  end
end
