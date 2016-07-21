Rails.application.routes.draw do

  # Sessions
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  # FriendshipRequests
  get 'friend-requests' => 'friendship_requests#index', as: :friendship_requests_received
  post 'friendship-request/:username' => 'friendship_requests#create', as: :add_friend
  delete 'friendship-request/:username' => 'friendship_requests#destroy', as: :reject_friendship_request

  # Friendships
  post 'friendship/:username' => 'friendships#create', as: :accept_friendship_request
  delete 'friendship/:username' => 'friendships#destroy', as: :end_friendship

  # Posts
  resources :posts, only: [:create, :show, :destroy]
  get '/new-post', to: 'posts#new', as: :new_post

  # Profiles -- this must be last
  get '/:username', to: 'profiles#show', as: :profile

  root 'sessions#new'
end
