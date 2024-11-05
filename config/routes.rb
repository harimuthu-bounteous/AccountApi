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
  put "/accounts/:id" => "accounts#update"
  delete "/accounts/:id" => "accounts#destroy"

  get "/transactions" => "transactions#index"
  get "/transactions/:id" => "transactions#show"
  post "/transactions" => "transactions#create"
end
