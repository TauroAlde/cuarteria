Rails.application.routes.draw do
  devise_for :users
  root to: 'dashboard#index'
  resources :sign_in, only: [:new, :create]
  resources :users, only: [:index, :new, :create]
  resources :dashboard, only: [:index, :new, :create]
  resources :consultations, only: [:index, :new, :create]
end
