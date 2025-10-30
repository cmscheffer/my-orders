Rails.application.routes.draw do
  devise_for :users
  
  # Define root path
  root "service_orders#index"
  
  # Service Orders routes
  resources :service_orders do
    member do
      patch :complete
      patch :cancel
    end
  end
  
  # Dashboard
  get "dashboard", to: "dashboard#index"
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
