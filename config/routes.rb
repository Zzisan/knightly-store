Rails.application.routes.draw do
  get "checkouts/new"
  get "checkouts/create"
  get "home/index"
  root 'home#index'
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :customers
  
  # Profile management
  resource :profile, only: [:show, :edit, :update]
  
  resources :products, only: [:index, :show]
  
  resource :cart, only: [:show], controller: 'cart' do
    post 'add/:product_id', action: :add, as: :add_to
    patch 'update/:product_id', action: :update, as: :update_item
    delete 'remove/:product_id', action: :remove, as: :remove_item
  end
  
  resources :checkouts, only: [:new, :create] do
    collection do
      get 'calculate_taxes_for_province'
      get 'preview_invoice'
    end
  end
  
  # Checkout with payment in one step
  resources :checkout_payments, only: [:new, :create]

  resources :orders, only: [:index, :show]
  
  # Static pages routes:
  get 'about', to: 'pages#show', defaults: { slug: 'about' }, as: :about
  get 'contact', to: 'pages#show', defaults: { slug: 'contact' }, as: :contact
  
  # Payment webhooks
  post "webhooks/payment_confirmation", to: "webhooks#payment_confirmation"
  post "webhooks/stripe", to: "webhooks#stripe"
  
  # Existing routes:
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # The dynamic show route that fetches a Page by its slug
  get 'pages/:slug', to: 'pages#show', as: :page
end
