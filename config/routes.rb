Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :shares, only: [ :new, :create ], param: :slug
  get "/:slug" => "shares#show", as: :share
  get "/:slug/edit" => "shares#edit", as: :edit_share
  patch "/:slug" => "shares#update", as: :update_share
end
