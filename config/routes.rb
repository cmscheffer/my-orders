Rails.application.routes.draw do
  devise_for :users
  
  # Define root path
  root "service_orders#index"
  
  # Service Orders routes
  resources :service_orders do
    member do
      patch :complete
      patch :cancel
      get :pdf
    end
  end
  
  # Parts routes
  resources :parts do
    member do
      patch :toggle_active
    end
  end
  
  # Technicians routes
  resources :technicians do
    member do
      patch :toggle_active
    end
  end
  
  # Dashboard
  get "dashboard", to: "dashboard#index"
  
  # Reports
  resources :reports, only: [:index] do
    collection do
      get :orders_by_period
      get :revenue
      get :technicians
      get :customers
    end
  end
  
  # Users routes
  resources :users
  
  # Company Settings
  resource :company_settings, only: [:edit, :update] do
    delete :remove_logo
    get :show_logo
  end
  
  # CSP Reports (Security)
  post "csp_reports", to: "csp_reports#create"
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
