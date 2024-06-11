Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index create show update destroy], path: :todolists do
      resources :todo_items, only: %i[index create show update destroy], path: :todoitems
    end
  end

  resources :todo_lists, only: %i[index new], path: :todolists
end
