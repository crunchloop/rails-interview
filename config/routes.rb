require "sidekiq/web" # require the web UI

Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
  end

  mount Sidekiq::Web => "/sidekiq" # access it at http://localhost:3000/sidekiq

  resources :todo_lists, except: %i[index] do
    resources :todo_items, only: %i[create edit update destroy] do
      patch :complete, on: :member
      patch :undo_complete, on: :member
    end
  end

  root to: "todo_lists#new"
end
