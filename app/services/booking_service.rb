class BookingService
  def self.find_booking(user_id)
    booking = Booking.find_by(user_id: user_id)

    return { error: "No existing booking found for user_id #{user_id}." }.to_json if booking.blank?

    booking.to_json
  end
end
