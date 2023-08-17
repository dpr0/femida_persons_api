Rails.application.routes.draw do
  apipie

  namespace :api do
    resources :search, only: :index do
      collection do
        get :by_fio
        get :by_phone
        get :by_address
      end
    end
  end
end
