Rails.application.routes.draw do
  devise_for :users
  root "birds#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  resources :images

  get("/birds/photo", { :controller => "birds", :action => "take_photo" })
  post("/birds/photo", { :controller => "birds", :action => "save_photo" })
  get("/uploads/:filename", { :controller => "uploads", :action => "show", constraints: { filename: /[^\/]+/ } })
  get("/export_birding_journal", { :controller => "birds", :action => "export", :as => "export_birding_journal" })
  resources :birds

end
