class BookingService
  def self.find_booking(user_id)
    booking = Booking.find_by(user_id: user_id)

    return { error: "No existing booking found for user_id #{user_id}." }.to_json if booking.blank?

    booking.to_json
  end

  def self.create_booking(user_id:, details:)
    booking = Booking.create!(user_id: user_id, details: details)

    booking.to_json
  rescue ActiveRecord::RecordInvalid => e
    { error: e.record.errors.full_messages.to_sentence }.to_json
  end
end
