Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
    post 'login', to: 'authentication#login'
    post 'signup', to: 'users#create'
  end

  resources :todo_lists, only: %i[index new], path: :todolists
end
