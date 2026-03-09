Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  # post '/signup', to: 'auth#signup'
  # post '/login', to: 'auth#login'
  # get  '/verify_token', to: 'auth#verify_token'
  devise_for :users, controllers: {
  sessions: "users/sessions",
  registrations: "users/registrations"
  }

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      post "auth/refresh", to: "auth#refresh"
      post "auth/logout", to: "auth#logout"
      get  "auth/me", to: "auth#me"
      post "auth/verify", to: "auth#verify"
    end
  end
end
