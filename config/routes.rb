Rails.application.routes.draw do
  devise_for :users
  root to: 'dashboard#index'
  resources :sign_in, only: [:new, :create]
  resources :user_profiles, only: [:index, :edit, :update]
  resources :dashboard, only: [:index, :new, :create]
  resources :consultations, only: [:index, :new, :create]
  resources :settings, only: [:index, :new, :create]
  resources :quotations, only: [:index, :show, :new]
  resources :shipments, only: [:index, :create]
end
