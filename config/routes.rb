Rails.application.routes.draw do
  get "home/index"
  root 'home#index'
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :customers
  
  resources :products, only: [:index, :show]
  
  # Cart routes
  resource :cart, only: [:show], controller: 'cart' do
    post 'add/:product_id', action: :add, as: :add_to
    patch 'update/:product_id', action: :update, as: :update_item
    delete 'remove/:product_id', action: :remove, as: :remove_item
  end
  
  # Checkout routes
  resource :checkout, only: [:new, :create]
  
  # Add index to orders so customers can see their past orders
  resources :orders, only: [:index, :show]
  
  # Existing routes:
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
