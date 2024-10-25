Rails.application.routes.draw do
  #Swagger docs
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  mount ActionCable.server => '/cable'
  
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
  end

  resources :todo_lists do
    member do
      post :complete
    end
  end

  resources :todo_lists do
    collection do
      post :generate_lists
    end
  end
  
  # resources :todo_lists, only: %i[index new create], path: :todolists
  resources :todo_lists, only: [:create, :index, :show, :new, :destroy]

end
