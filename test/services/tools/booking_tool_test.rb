require "test_helper"

module Tools
  class BookingToolTest < ActiveSupport::TestCase
    test "booking runs through an instance method for Langchain tool execution" do
      BookingService.stub(:find_booking, "{\"id\":1}") do
        assert_equal "{\"id\":1}", BookingTool.new.booking(user_id: "1")
      end
    end

    test "booking handles malformed tool arguments from the model" do
      assert_equal(
        "Please provide a user_id to look up an existing booking.",
        BookingTool.new.booking(query: "Book Trident Bandra Kurla Mumbai")
      )
    end

    test "create booking runs through an instance method for Langchain tool execution" do
      BookingService.stub(:create_booking, "{\"id\":1}") do
        assert_equal(
          "{\"id\":1}",
          BookingTool.new.create_booking(user_id: "1", details: "Hotel stay in Mumbai")
        )
      end
    end

    test "create booking asks for missing user_id" do
      assert_equal(
        "Please provide a user_id to create a booking.",
        BookingTool.new.create_booking(details: "Hotel stay in Mumbai")
      )
    end

    test "create booking asks for missing details" do
      assert_equal(
        "Please provide booking details to create a booking.",
        BookingTool.new.create_booking(user_id: "1")
      )
    end
  end
end
