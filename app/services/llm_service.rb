class LlmService
  DEFAULT_OLLAMA_URL = "http://localhost:11434"
  DEFAULT_CHAT_MODEL = "gemma:2b"
  DEFAULT_EMBEDDING_MODEL = "nomic-embed-text"

  def self.client
    @client ||= Langchain::LLM::Ollama.new(
      url: ollama_url,
      default_options: {
        chat_model: chat_model,
        completion_model: chat_model,
        embedding_model: embedding_model,
        temperature: temperature
      }
    )
  end

  def self.chat_model
    ENV.fetch("OLLAMA_CHAT_MODEL", DEFAULT_CHAT_MODEL)
  end

  def self.embedding_model
    ENV.fetch("OLLAMA_EMBEDDING_MODEL", DEFAULT_EMBEDDING_MODEL)
  end

  def self.ollama_url
    ENV.fetch("OLLAMA_URL", DEFAULT_OLLAMA_URL)
  end

  def self.temperature
    ENV.fetch("OLLAMA_TEMPERATURE", "0.2").to_f
  end

  def self.reset_client!
    @client = nil
  end
end
