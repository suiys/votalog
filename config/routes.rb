Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  devise_scope :user do
    post 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
  end
  root 'home#index'
  get 'users/account', to: 'users#show'
  resources :plants, except: :index
  resources :logs, except: :index
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
