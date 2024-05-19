Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :todo_lists, only: %i[index], path: :todolists do
        resources :todo_items, only: %i[index create update destroy], path: :items

        member do
          patch :complete_all
        end
      end
    end
  end

  resources :todo_lists, only: %i[index new], path: :todolists
end
