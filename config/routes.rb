Rails.application.routes.draw do

  # SessionsController
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  # ProfilesController
  get '/:username', to: 'profiles#show', as: :profile

  root 'sessions#new'
end
