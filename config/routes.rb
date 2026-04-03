# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index create update destroy], path: :todolists do
      resources :todo_items, only: %i[index create update destroy], path: :todos, as: :todos
    end
  end

  resources :todo_lists, only: %i[index new edit create update destroy], path: :todolists do
    member do
      post :complete_all
    end

    resources :todo_items, only: %i[index new create edit update destroy], path: :todos, as: :todos do
      member do
        patch :complete
      end
      collection do
        match :autofill, via: [:post, :patch]
      end
    end
  end

  root to: 'todo_lists#index'
end
