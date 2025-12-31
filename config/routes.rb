Rails.application.routes.draw do
  root "shares#new"

  get "about" => "shares#about", as: :about

  resources :shares, only: [ :new, :create ], param: :slug
  get "/:slug" => "shares#show", as: :share
  get "/:slug/edit" => "shares#edit", as: :edit_share
  patch "/:slug" => "shares#update", as: :update_share
end
