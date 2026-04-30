class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.integer :user_id
      t.text :details

      t.timestamps
    end
  end
end
