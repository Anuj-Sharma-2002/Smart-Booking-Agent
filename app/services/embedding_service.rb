class EmbeddingService
  include HTTParty
  base_uri 'http://localhost:11434'

  def self.embed(text)
    response = post('/api/embeddings', {
      headers: { 'Content-Type' => 'application/json' },
      body: {
        model: "nomic-embed-text",
        prompt: text
      }.to_json
    })

    JSON.parse(response.body)["embedding"]
  end
end