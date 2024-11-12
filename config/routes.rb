# config/routes.rb
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post "/auth/register" => "users#register"
      post "/auth/login" => "users#login"
      post "/auth/admin/register" => "users#register_admin"

      # Account routes
      resources :accounts, param: :account_number, only: [ :index, :show, :create, :update, :destroy ] do
        member do
          get :transactions, to: "transactions#show_transactions"
          post :transactions, to: "transactions#create"
        end
      end

      # Transaction routes
      resources :transactions, only: [ :index, :show, :update, :destroy ]
    end
  end
end
