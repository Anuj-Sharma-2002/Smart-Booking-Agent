# app/services/rag_answer_service.rb
class RagAnswerService
  def self.answer(query)
    docs = RagService.search(query)

    context = docs.map(&:content).join("\n")

    LlmService.ask(<<~PROMPT)
      Answer the question using the context below.

      Context:
      #{context}

      Question:
      #{query}
    PROMPT
  end
end