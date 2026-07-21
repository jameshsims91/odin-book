Rails.application.routes.draw do
  get "notifications/index"
  get "comment_likes/create"
  get "comment_likes/destroy"
  get "c_omment_likes/create"
  get "c_omment_likes/destroy"
  get "comments/create"
  get "likes/create"
  get "likes/destroy"
  get "users/index"
  resources :posts
  resources :profiles
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # root "devise/sessions#new"

  authenticated :user do
    resource :profile, only: [ :show, :edit, :update ]
    resources :posts, only: [ :index, :create, :destroy ] do
      resources :likes, only: [ :create, :destroy ]
      resources :comments, only: [ :create, :destroy ] do
        resources :comment_likes, only: [ :create, :destroy ]
      end
    end
    resources :friendships, only: [ :create, :update, :destroy ]
    resources :users, only: [ :index, :show ]
    resources :notifications, only: [ :index ] do
      collection do
        delete :clear_all
      end
    end
    root to: "profiles#show", as: :authenticated_root
  end

  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
