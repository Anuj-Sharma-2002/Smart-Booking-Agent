# frozen_string_literal: true

# Rack middleware that validates a shared API key on all /api/* routes.
# This protects your Ollama tunnel from unauthorized use.
#
# Configuration:
#   Set OLLAMA_API_KEY env var on both your local machine (in .env) and on Render.
#   Rails services automatically send this key via the X-Ollama-Api-Key header.
#
# To enable: add `config.middleware.use OllamaAuthMiddleware` in config/application.rb
#
class OllamaAuthMiddleware
  # Paths that require authentication
  PROTECTED_PATHS = %w[/api/generate /api/chat /api/embeddings /api/tags /api/show].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if ollama_path?(request.path) && api_key_configured?
      provided_key = env["HTTP_X_OLLAMA_API_KEY"].to_s
      expected_key = ENV["OLLAMA_API_KEY"].to_s

      unless ActiveSupport::SecurityUtils.secure_compare(expected_key, provided_key)
        Rails.logger.warn("[OllamaAuthMiddleware] Unauthorized request to #{request.path} from #{request.ip}")
        return [ 401, { "Content-Type" => "application/json" }, [ '{"error":"Unauthorized"}' ] ]
      end
    end

    @app.call(env)
  end

  private

  def ollama_path?(path)
    PROTECTED_PATHS.any? { |p| path.start_with?(p) }
  end

  def api_key_configured?
    ENV["OLLAMA_API_KEY"].present?
  end
end
