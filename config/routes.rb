Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  apipie
  devise_for :users

  resources :users
  resources :files

  namespace :api do
    namespace :persons do
      resources :search, only: :index do
        collection do
          get :by_fio
          get :by_phone
          get :by_address
        end
      end
    end
  end
end
