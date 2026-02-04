Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
  end

  resources :todo_lists, only: %i[show new create] do
    resources :todo_items, only: %i[new create]
  end

  root to: "todo_lists#new"
end
