# very clean routes! I like the use of the authenticate method to only allow admins to access the RailsAdmin dashboard
Rails.application.routes.draw do
  resources :tasks
  # great!
  authenticate :user, ->(user) { user.admin? } do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end

  devise_for :users
  root "birds#index"

  get("/birds/photo", { :controller => "birds", :action => "take_photo" })
  post("/birds/photo", { :controller => "birds", :action => "save_photo" })

  get("/birds/camera", { :controller => "birds", :action => "take_camera" })
  post("/birds/camera", { :controller => "birds", :action => "save_camera" })

  get("/birds/export", { :controller => "birds", :action => "export"})
  resources :birds

end
