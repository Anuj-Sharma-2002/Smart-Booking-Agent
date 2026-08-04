module Tools
  class FaqTool
    extend Langchain::ToolDefinition

    define_function :faq,
      description: "Answer questions from the local FAQ or knowledge base" do

      property :query,
        type: "string",
        description: "Question to search in the knowledge base",
        required: true
    end

    def faq(query:)
      Rails.logger.info("[Tool Used] FaqTool.faq query=#{query.inspect}")

      docs = RagService.search(query)
      context = docs.map(&:content).join("\n")

      context.presence || "No matching FAQ or knowledge base content found."
    end
  end
end
