class ChatController < ApplicationController
	def ask
		query = params[:query]
		response = AgentService.run(query)

		render json: { response: response }
	end
end
