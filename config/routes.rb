require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    resources :todo_lists, only: %i[index show create update destroy], path: :todolists do
      member do
        patch :bulk_update_state
      end
      resources :todo_items, only: %i[index show create update destroy], path: :items
    end
  end

  resources :todo_lists, only: %i[index show new create edit update destroy], path: :todolists do
    resources :todo_items, only: %i[new create edit update destroy], path: :items
  end
end
