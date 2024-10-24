Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
  end

  resources :todo_lists do
    member do
      post :complete
    end
  end

  # resources :todo_lists, only: %i[index new create], path: :todolists
  resources :todo_lists, only: [:create, :index, :show, :new, :destroy]

end
