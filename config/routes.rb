Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "/auth/register" => "users#register"
  post "/auth/login" => "users#login"
  post "/auth/admin/register" => "users#register_admin"

  get "/accounts" => "accounts#index"
  get "/accounts/:account_number" => "accounts#show"
  post "/accounts" => "accounts#create"
  put "/accounts/:account_number" => "accounts#update"
  delete "/accounts/:account_number" => "accounts#destroy"

  get "/transactions" => "transactions#index"
  get "/transactions/:id" => "transactions#show"
  post "/accounts/:account_number/transactions" => "transactions#create"
  put "/transactions/:id" => "transactions#update"
  delete "/transactions/:id" => "transactions#destroy"
end
