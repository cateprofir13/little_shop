Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Search Endpoints
  namespace :api do
    namespace :v1 do
      namespace :merchants do
        controller :search do
          get :find, action: :show
          get :find_all, action: :index
        end
      end
    end
  end
  namespace :api do
    namespace :v1 do
      resources :items, only: [:find, :find_all] do
      end
    end
  end
  # Merchant endpoints
  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show, :create, :update, :destroy] do
      end
    end
  end  
  # Merchant nested endpoints
  namespace :api do
    namespace :v1 do
      resources :merchants, only: [] do
        resources :items, only: [:index], controller: 'merchant_items'
        resources :customers, only: [:index], controller: 'merchant_customers'
        resources :invoices, only: [:index], controller: 'merchant_invoices'
      end
    end
  end
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