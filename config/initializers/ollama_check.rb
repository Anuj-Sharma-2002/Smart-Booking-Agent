# frozen_string_literal: true

# Warn at boot if OLLAMA_URL is not configured in production.
# This surfaces the missing config immediately rather than failing on the first request.

if Rails.env.production?
  if ENV["OLLAMA_URL"].blank?
    Rails.logger.warn(
      "[Ollama] WARNING: OLLAMA_URL is not set. " \
      "AI features (chat, embeddings, RAG) will fail. " \
      "Set OLLAMA_URL to your Cloudflare Tunnel or ngrok URL in Render environment variables."
    )
  else
    Rails.logger.info("[Ollama] Using Ollama at: #{ENV['OLLAMA_URL']}")
    Rails.logger.info("[Ollama] Chat model:       #{ENV.fetch('OLLAMA_CHAT_MODEL', 'llama3.1:8b')}")
    Rails.logger.info("[Ollama] Embedding model:  #{ENV.fetch('OLLAMA_EMBEDDING_MODEL', 'nomic-embed-text')}")
    Rails.logger.info("[Ollama] API key set:      #{ENV['OLLAMA_API_KEY'].present?}")
    Rails.logger.info("[Ollama] CF Access set:    #{ENV['CF_ACCESS_CLIENT_ID'].present?}")
  end
end
