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

    def booking(user_id: nil, **)
      return "Please provide a user_id to look up an existing booking." if user_id.blank?

      BookingService.find_booking(user_id)
    end
  end
end
