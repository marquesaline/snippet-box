Rails.application.routes.draw do
  root "shares#new"

  get "about" => "shares#about", as: :about
  get "sitemap.xml" => "shares#sitemap", as: :sitemap, defaults: { format: "xml" }

  resources :shares, only: [ :new, :create ], param: :slug
  get "/:slug" => "shares#show", as: :share
  get "/:slug/raw" => "shares#raw", as: :raw_share
  get "/:slug/edit" => "shares#edit", as: :edit_share
  patch "/:slug" => "shares#update", as: :update_share
  post "/:slug/fork" => "shares#fork", as: :fork_share
  delete "/:slug" => "shares#destroy", as: :destroy_share
end
