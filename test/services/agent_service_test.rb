require "test_helper"

class AgentServiceTest < ActiveSupport::TestCase
  setup do
    @original_chat_model = ENV["OLLAMA_CHAT_MODEL"]
    @original_enable_tools = ENV["OLLAMA_ENABLE_TOOLS"]
    LlmService.reset_client!
  end

  teardown do
    restore_env("OLLAMA_CHAT_MODEL", @original_chat_model)
    restore_env("OLLAMA_ENABLE_TOOLS", @original_enable_tools)
    LlmService.reset_client!
  end

  test "does not send tools to Ollama models that do not support function calling" do
    ENV["OLLAMA_CHAT_MODEL"] = "gemma:2b"
    ENV.delete("OLLAMA_ENABLE_TOOLS")
    LlmService.reset_client!

    assert_empty AgentService.tools
    assert_not AgentService.instructions.include?("You have access to the following tools")
  end

  test "allows tools when explicitly enabled" do
    ENV["OLLAMA_CHAT_MODEL"] = "gemma:2b"
    ENV["OLLAMA_ENABLE_TOOLS"] = "true"
    LlmService.reset_client!

    assert_equal 2, AgentService.tools.size
    assert AgentService.instructions.include?("You have access to the following tools")
  end

  test "returns last assistant message content from langchain response" do
    response = [
      { "role" => "system", "content" => "System prompt" },
      { "role" => "user", "content" => "Find me hotels in Mumbai" },
      { "role" => "assistant", "content" => "Here are hotel options in Mumbai." }
    ]

    assert_equal "Here are hotel options in Mumbai.", AgentService.response_text(response)
  end

  private

  def restore_env(key, value)
    if value.nil?
      ENV.delete(key)
    else
      ENV[key] = value
    end
  end
end
