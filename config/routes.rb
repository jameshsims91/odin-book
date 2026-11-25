
Rails.application.routes.draw do
  resources :posts
  resources :profiles
  devise_for :users

  # Public entry point for the read-only recruiter demo.
  post "demo", to: "demo_sessions#create", as: :demo_login

  authenticated :user do
    resource :profile, only: [ :show, :edit, :update ]

    resources :web_push_subscriptions, only: [ :create ]
    resources :friends, only: [ :index ]

    resources :posts, only: [ :index, :create, :destroy ] do
      resources :likes, only: [ :create, :destroy ]

      resources :comments, only: [ :create, :destroy ] do
        resources :comment_likes, only: [ :create, :destroy ]
      end
    end

    resources :friendships, only: [ :create, :update, :destroy ]

    resources :users, only: [ :index, :show ] do
      collection do
        get :search
      end
    end

    resources :notifications, only: [ :index ] do
      collection do
        delete :clear_all
      end
    end

    root to: "profiles#show", as: :authenticated_root

    get "attachments/users/:id/avatar",
        to: "attachments#avatar",
        as: :user_avatar

    get "attachments/posts/:id/:size",
        to: "attachments#post_image",
        as: :post_image
  end

  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  get "/google161cda089d7aa7bb.html",
      to: proc { [ 200, {}, [ "google-site-verification: google161cda089d7aa7bb.html" ] ] }
end
