# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, except: %i[new edit], path: :todolists do
      resources :todo_items, except: %i[new edit], path: :todoitems
    end
  end

  resources :todo_lists, path: :todolists do
    resources :todo_items, path: :todoitems
  end
end
