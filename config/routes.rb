Rails.application.routes.draw do
  authenticate :user, ->(user) { user.admin? } do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end

  devise_for :users
  root "birds#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  get("/birds/photo", { :controller => "birds", :action => "take_photo" })
  post("/birds/photo", { :controller => "birds", :action => "save_photo" })
  get("/birds/export", { :controller => "birds", :action => "export" })
  get "/birds/json_pdf", to: "birds#json_pdf", as: :json_pdf
  get("/uploads/:filename", { :controller => "uploads", :action => "show", constraints: { filename: /[^\/]+/ } })
  resources :birds
  resources :images

end
