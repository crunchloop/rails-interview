Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
  end

  resources :todo_lists, only: %i[index new show], path: :todolists do
    post :mark_all_todo_items_as_complete, on: :member
    resources :todo_items do
      patch :mark_as_complete, on: :member
    end
  end
end
