Rails.application.routes.draw do
  get 'dashboard/index'
  resources :sign_in, only: [:new, :create]
  resources :users, only: [:index, :new, :create]

  root to: "sign_in#index"
end
