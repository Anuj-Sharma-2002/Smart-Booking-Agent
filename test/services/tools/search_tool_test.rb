require "test_helper"

module Tools
  class SearchToolTest < ActiveSupport::TestCase
    test "search runs through an instance method for Langchain tool execution" do
      SearchService.stub(:search, "Hotel results") do
        assert_equal "Hotel results", SearchTool.new.search(query: "hotels in Mumbai")
      end
    end
  end
end
