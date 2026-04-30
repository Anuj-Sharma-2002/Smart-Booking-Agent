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
  end
end
