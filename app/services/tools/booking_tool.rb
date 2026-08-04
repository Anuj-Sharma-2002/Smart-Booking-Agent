module Tools
  class BookingTool
    extend Langchain::ToolDefinition

    define_function :booking,
      description: "Look up existing booking details by user_id. Do not use this to create a new hotel booking." do

      property :user_id,
        type: "string",
        description: "User ID for an existing booking lookup",
        required: true
    end

    define_function :create_booking,
      description: "Create a new booking for a user. Use only when the user provides user_id and booking details." do

      property :user_id,
        type: "string",
        description: "User ID for the new booking",
        required: true

      property :details,
        type: "string",
        description: "Booking details such as hotel name, check-in date, check-out date, guest count, and contact information",
        required: true
    end

    def booking(user_id: nil, **)
      Rails.logger.info("[Tool Used] BookingTool.booking user_id=#{user_id.inspect}")

      return "Please provide a user_id to look up an existing booking." if user_id.blank?

      BookingService.find_booking(user_id)
    end

    def create_booking(user_id: nil, details: nil, **)
      Rails.logger.info("[Tool Used] BookingTool.create_booking user_id=#{user_id.inspect} details=#{details.inspect}")

      return "Please provide a user_id to create a booking." if user_id.blank?
      return "Please provide booking details to create a booking." if details.blank?

      BookingService.create_booking(user_id: user_id, details: details)
    end
  end
end
