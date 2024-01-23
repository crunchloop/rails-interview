Rails.application.routes.draw do
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

  root to: 'admin/dashboard#index'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    resources :todo_lists, only: %i[index create update destroy], path: :todolists do
      resources :todo_items, only: %i[index create update destroy], path: :todoitems
    end
  end

  resources :todo_lists, only: %i[index show new create edit update destroy], path: :todolists do
    resources :todo_items, only: %i[index create update destroy new show edit], path: :todoitems
  end
end
