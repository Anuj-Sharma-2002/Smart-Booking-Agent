class AgentService
  TOOL_CAPABLE_OLLAMA_MODELS = [
    /\Allama3(?:\.\d+)?:/i,
    /\Aqwen2(?:\.\d+)?:/i,
    /\Amistral/i
  ].freeze


#   /\Allama3(?:\.\d+)?:/i
# \A → matches start of the string
# llama3 → matches the literal text "llama3"
# (?:\.\d+)? → optional:
# \. = a dot
# \d+ = one or more digits
# → matches things like .1, .2, etc.
# : → requires a colon after the name
# i → case-insensitive

  INSTRUCTIONS_WITH_TOOLS = <<~TEXT
			You are a helpful AI assistant.

			You have access to the following tools:
			- SearchTool: Use this to find information, answer general questions, or retrieve data.
			- BookingTool: Use this only to look up existing booking details by user_id.

			Guidelines:
			- Always use tools when they are relevant instead of guessing.
			- Do not make up information if a tool can provide it.
			- Ask clarifying questions if the user request is incomplete.
			- Be concise and clear in your responses.
			- If no tool is needed, answer directly.

			Booking rules:
			- Do not call BookingTool to create a new hotel booking or reservation.
			- Only call BookingTool when the user asks to look up an existing booking and provides a user_id.
			- For new hotel booking requests, ask for the missing details needed to book, such as check-in date, check-out date, guest count, and contact details.

			Search rules:
			- Use SearchTool for factual or external information.

			Always prioritize accuracy over speed.
		TEXT

  INSTRUCTIONS_WITHOUT_TOOLS = <<~TEXT
      You are a helpful AI assistant.

      You are running with a local Ollama model that does not support tool/function calling.
      Do not claim that you searched the internet or completed a booking unless the user gives you enough details and the application actually provides that capability.

      Guidelines:
      - Ask clarifying questions if the user request is incomplete.
      - Be concise and clear in your responses.
      - For booking requests, ask for missing details like check-in date, check-out date, guest count, contact details, and user ID before proceeding.
      - For factual or external information that may be current, say that you cannot verify live data from this model.

      Always prioritize accuracy over speed.
    TEXT

  def self.agent
    Langchain::Assistant.new(
      llm: LlmService.client,
      tools: tools,
      instructions: instructions
    )
  end

  def self.run(query)
    response_text(agent.add_message_and_run!(content: query))
  end

  def self.response_text(response)
    return response if response.is_a?(String)

    if response.is_a?(Array)
      assistant_message = response.reverse.find do |message|
        message_role(message) == "assistant" && message_content(message).present?
      end

      return message_content(assistant_message) if assistant_message
    end

    message_content(response) || response
  end

  def self.tools
    tools_supported? ? [Tools::SearchTool.new, Tools::BookingTool.new] : []
  end

  def self.instructions
    tools_supported? ? INSTRUCTIONS_WITH_TOOLS : INSTRUCTIONS_WITHOUT_TOOLS
  end

  def self.tools_supported?
    return explicit_tool_support if explicit_tool_support_configured?
    return true unless LlmService.client.is_a?(Langchain::LLM::Ollama)

    TOOL_CAPABLE_OLLAMA_MODELS.any? { |pattern| LlmService.chat_model.match?(pattern) }
  end

  def self.explicit_tool_support_configured?
    ENV.key?("OLLAMA_ENABLE_TOOLS")
  end

  def self.explicit_tool_support
    ActiveModel::Type::Boolean.new.cast(ENV.fetch("OLLAMA_ENABLE_TOOLS"))
  end

  def self.message_role(message)
    return message["role"] if message.is_a?(Hash) && message.key?("role")
    return message[:role] if message.is_a?(Hash) && message.key?(:role)
    return message.role if message.respond_to?(:role)
  end

  def self.message_content(message)
    return if message.blank?
    return message["content"] if message.is_a?(Hash) && message.key?("content")
    return message[:content] if message.is_a?(Hash) && message.key?(:content)
    return message.content if message.respond_to?(:content)
  end
end
