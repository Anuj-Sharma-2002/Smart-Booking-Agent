Rails.application.routes.draw do
  post "/chat", to: "chat#ask"
end
