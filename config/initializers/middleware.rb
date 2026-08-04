# frozen_string_literal: true

require_relative "../../app/middleware/ollama_auth_middleware"

# Protect Ollama API routes with a shared secret key.
# Only active when OLLAMA_API_KEY env var is set.
Rails.application.config.middleware.use OllamaAuthMiddleware
