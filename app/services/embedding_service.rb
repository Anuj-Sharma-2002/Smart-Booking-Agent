class EmbeddingService
  include HTTParty

  def self.base_ollama_url
    ENV.fetch("OLLAMA_URL", "http://localhost:11434")
  end

  def self.embedding_model
    ENV.fetch("OLLAMA_EMBEDDING_MODEL", "nomic-embed-text")
  end

  def self.embed(text)
    headers = { "Content-Type" => "application/json" }

    # Shared API key authentication
    headers["X-Ollama-Api-Key"] = ENV["OLLAMA_API_KEY"] if ENV["OLLAMA_API_KEY"].present?

    # Cloudflare Zero Trust Service Token (optional)
    if ENV["CF_ACCESS_CLIENT_ID"].present?
      headers["CF-Access-Client-Id"]     = ENV["CF_ACCESS_CLIENT_ID"]
      headers["CF-Access-Client-Secret"] = ENV["CF_ACCESS_CLIENT_SECRET"]
    end

    response = HTTParty.post(
      "#{base_ollama_url}/api/embeddings",
      headers: headers,
      body: { model: embedding_model, prompt: text }.to_json,
      timeout: 60
    )

    unless response.success?
      Rails.logger.error("[EmbeddingService] HTTP #{response.code}: #{response.body}")
      raise "Embedding request failed with status #{response.code}"
    end

    JSON.parse(response.body)["embedding"]
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error("[EmbeddingService] Timeout connecting to Ollama at #{base_ollama_url}: #{e.message}")
    raise
  rescue Errno::ECONNREFUSED => e
    Rails.logger.error("[EmbeddingService] Connection refused to Ollama at #{base_ollama_url}: #{e.message}")
    raise
  rescue JSON::ParserError => e
    Rails.logger.error("[EmbeddingService] Invalid JSON from Ollama: #{e.message}")
    raise
  end
end