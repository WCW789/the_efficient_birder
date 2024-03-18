Rails.application.routes.draw do
  resources :images
  resources :birds
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "birds#index"
end
