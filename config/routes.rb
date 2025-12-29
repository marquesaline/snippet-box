Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :shares, only: [ :new, :create, :edit, :update ]
  get "/:slug" => "shares#show", as: :slug
end
