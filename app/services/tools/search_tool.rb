module Tools
  class SearchTool
    extend Langchain::ToolDefinition

    define_function :search,
      description: "Search real-time information from internet" do

      property :query,
        type: "string",
        description: "Search query",
        required: true
    end

    def search(query:)
      SearchService.search(query)
    end
  end
end
