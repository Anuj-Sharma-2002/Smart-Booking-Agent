Rails.application.routes.draw do
  root to: redirect("/index.html")

  post "/chat", to: "chat#ask"
end
