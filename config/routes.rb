Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    resources :todo_lists, only: %i[index update], path: :todolists do
      resources :todo_list_items, only: %i[create update destroy]
      resource :bulk_actions, only: %i[create], controller: "bulk_actions"
    end
  end

  resources :todo_lists, only: %i[index new create], path: :todolists

  root "landing#index"
end
