Rails.application.routes.draw do

  # SessionsController
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  get '/:username', to: 'users#show', as: :user

  resources :users, except: :show
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'users#index'
end
