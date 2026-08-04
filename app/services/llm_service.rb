class LlmService
  DEFAULT_OLLAMA_URL = "http://localhost:11434"
  DEFAULT_CHAT_MODEL = "llama3.1:8b"
  DEFAULT_EMBEDDING_MODEL = "nomic-embed-text"
  DEFAULT_OLLAMA_TIMEOUT = 180

  def self.client
    @client ||= configure_ollama_timeouts(
      Langchain::LLM::Ollama.new(
        url: ollama_url,
        default_options: {
          chat_model:       chat_model,
          completion_model: chat_model,
          embedding_model:  embedding_model,
          temperature:      temperature
        }
      )
    )
  end

  def self.ask(prompt)
    response = client.chat(messages: [ { role: "user", content: prompt } ])
    response.chat_completion.presence || response.completion
  end

  # Reads from OLLAMA_CHAT_MODEL env var (falls back to default)
  def self.chat_model
    ENV.fetch("OLLAMA_CHAT_MODEL", DEFAULT_CHAT_MODEL)
  end

  # Reads from OLLAMA_EMBEDDING_MODEL env var (falls back to default)
  def self.embedding_model
    ENV.fetch("OLLAMA_EMBEDDING_MODEL", DEFAULT_EMBEDDING_MODEL)
  end

  # Reads from OLLAMA_URL env var so Render can point at the tunnel
  def self.ollama_url
    ENV.fetch("OLLAMA_URL", DEFAULT_OLLAMA_URL)
  end

  def self.temperature
    ENV.fetch("OLLAMA_TEMPERATURE", "0.2").to_f
  end

  def self.ollama_timeout
    ENV.fetch("OLLAMA_TIMEOUT", DEFAULT_OLLAMA_TIMEOUT).to_i
  end

  def self.reset_client!
    @client = nil
  end

  def self.configure_ollama_timeouts(client)
    faraday_client = client.send(:client)
    faraday_client.options.timeout      = ollama_timeout
    faraday_client.options.open_timeout = 10

    # Shared API key (X-Ollama-Api-Key header) for basic auth
    if ENV["OLLAMA_API_KEY"].present?
      faraday_client.headers["X-Ollama-Api-Key"] = ENV["OLLAMA_API_KEY"]
    end

    # Cloudflare Zero Trust Service Token headers (optional, most secure)
    if ENV["CF_ACCESS_CLIENT_ID"].present?
      faraday_client.headers["CF-Access-Client-Id"]     = ENV["CF_ACCESS_CLIENT_ID"]
      faraday_client.headers["CF-Access-Client-Secret"] = ENV["CF_ACCESS_CLIENT_SECRET"]
    end

    client
  end
end
