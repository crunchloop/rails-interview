Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
  end

  resources :todo_lists, except: %i[index] do
    resources :todo_items, only: %i[create destroy] do
      patch :complete, on: :member
      patch :undo_complete, on: :member
    end
  end

  root to: "todo_lists#new"
end
