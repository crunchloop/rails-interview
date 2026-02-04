Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
  end

  resources :todo_lists, except: %i[index] do
    resources :todo_items, only: %i[create destroy]
  end

  root to: "todo_lists#new"
end
