class ChatController < ApplicationController
  def ask
    query = params[:query]
    response = AgentService.run(query)

    render json: { response: response }
  rescue Faraday::TimeoutError, Net::ReadTimeout
    render json: {
      error: "The local AI model took too long to respond. Please try again, or use a smaller/faster Ollama model."
    }, status: :gateway_timeout
  end
end
