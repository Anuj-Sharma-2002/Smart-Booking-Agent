# app/services/memory_service.rb
class MemoryService
  def self.memory
    Langchain::Memory::ConversationBufferMemory.new(
      memory_key: "chat_history"
    )
  end
end