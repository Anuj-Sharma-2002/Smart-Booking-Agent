# app/services/rag_service.rb
class RagService
  def self.search(query)
    query_embedding = EmbeddingService.embed(query)

    Document
      .nearest_neighbors(:embedding, query_embedding, distance: "cosine")
      .limit(3)
  end
end