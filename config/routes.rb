Rails.application.routes.draw do
  resources :posts
  resources :profiles
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # root "devise/sessions#new"

  authenticated :user do
    resource :profile, only: [ :show, :edit, :update ]
    resources :posts, only: [ :create ]
    root to: "profiles#show", as: :authenticated_root
  end

  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
