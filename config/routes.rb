Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Search Endpoints
  get "/api/v1/merchants/find", to: "api/v1/merchants/search#show"
  get "/api/v1/merchants/find_all", to: "api/v1/merchants/search#index"
  get "/api/v1/items/find_all", to: "api/v1/items/search#index"
  
  # Merchant endpoints
  get "/api/v1/merchants", to: "api/v1/merchants#index"
  get "/api/v1/merchants/:id", to: "api/v1/merchants#show"
  post "/api/v1/merchants", to: "api/v1/merchants#create"
  patch "/api/v1/merchants/:id", to: "api/v1/merchants#update"
  put "/api/v1/merchants/:id", to: "api/v1/merchants#update"
  delete "/api/v1/merchants/:id", to: "api/v1/merchants#destroy"
  
  # Merchant nested endpoints
  get "/api/v1/merchants/:merchant_id/items", to: "api/v1/merchant_items#index"
  get "/api/v1/merchants/:merchant_id/customers", to: "api/v1/merchant_customers#index"
  get "/api/v1/merchants/:merchant_id/invoices", to: "api/v1/merchant_invoices#index"
  
  # Item endpoints
  get "/api/v1/items", to: "api/v1/items#index"
  get "/api/v1/items/:id", to: "api/v1/items#show"
  post "/api/v1/items", to: "api/v1/items#create"
  patch "/api/v1/items/:id", to: "api/v1/items#update"
  put "/api/v1/items/:id", to: "api/v1/items#update"
  delete "/api/v1/items/:id", to: "api/v1/items#destroy"
  
  # Item nested endpoints
  get "/api/v1/items/:item_id/merchant", to: "api/v1/item_merchants#show"
end