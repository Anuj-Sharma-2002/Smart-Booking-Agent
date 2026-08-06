
## 🚀 Tech Stack
Ruby on Rails 8.0.5 (API-only mode)

Ruby version 3.4.7

Postgresql 15 (development & test environments)

Ollama 0.21.0

## Ollama Setup (Install & Run Ollama)

 1. Install Ollama: curl -fsSL https://ollama.com/install.sh | sh

 2. Start Ollama: ollama serve

 3. Pull a model (recommended lightweight + strong reasoning): ollama pull llama3 

 4. ollama pull nomic-embed-text

## 🔑 Getting Your API Key

To use this project, you’ll need an API key from SearchAPI.

1. Go to: https://www.searchapi.io/
2. Sign up or log in to your account
3. Navigate to your dashboard
4. Generate or copy your API key

Once you have your API key, add it to your environment variables or configuration file as shown below:

```
SEARCHAPI_KEY=your_api_key_here
```

Make sure to keep your API key secure and do not share it publicly.

## Project Setup

bundle install

rails db:create db:migrate db:seed

rails server

Ollama server

## 📡 API Endpoints

http://localhost:3000/chat

## 🏗 Architecture Overview

This project leverages **LangChain** to intelligently route user queries across multiple tools. It follows a **tool-based architecture**, where the system dynamically selects and invokes the most appropriate tool based on user intent.

---

## 🔧 Core Components

The application integrates three primary tools:

### 1. 🔍 Search Tool

Handles queries that require **external information retrieval**.

- Fetches real-time data from the internet  
- Useful for discovery and general queries  
- **Example:** Finding hotels, destinations, or travel information  

---

### 2. 🛎 Booking Tool

Manages **reservation and booking operations** within the system.

- Interacts with the internal database  
- Supports booking creation and persistence  
- **Example:** Reserving a hotel or service  

---

### 3. ❓ FAQ Tool

Provides **quick responses to frequently asked questions**.

- Powered by Elasticsearch for efficient retrieval  
- Uses indexed data for accurate answers  
- Optimized for low-latency lookups  

---

## 🧠 Intelligent Routing

Using LangChain’s agent capabilities, the system:

- Analyzes incoming user queries  
- Determines the most appropriate tool  
- Automatically routes requests without manual intervention  

---

## 🚀 Key Benefits

This architecture ensures:

- **Scalability** – Easily extendable with additional tools  
- **Modularity** – Independent components for better maintainability  
- **Efficiency** – Fast and accurate handling of diverse queries  
- **Flexibility** – Adapts dynamically to different user intents  






