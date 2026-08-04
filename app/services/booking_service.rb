class BookingService
  def self.find_booking(user_id)
    bookings = Booking.where(user_id: user_id)

    return { error: "No existing bookings found for user_id #{user_id}." }.to_json if bookings.blank?

    bookings.to_json
  end

  def self.create_booking(user_id:, details:)
    booking = Booking.create!(user_id: user_id, details: details)

    booking.to_json
  rescue ActiveRecord::RecordInvalid => e
    { error: e.record.errors.full_messages.to_sentence }.to_json
  end
end
