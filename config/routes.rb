class AuthenticationConstraint

  # Signed-in users only
  def matches?(request)
    request.session[:user_id].present?
  end
end

Rails.application.routes.draw do

  # External
  resources :pending_newsletter_subscriptions, only: :create do
    get 'confirm', on: :collection
  end

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
  resources :posts, only: [:new, :create, :show, :destroy], :path => "post" do
    resources :comments, only: [:create, :destroy], :path => "comment"
  end

  # Private Conversations & Messages
  resources :private_conversations, only: [:new, :create, :show, :update, :destroy], :path => "conversation"
  get '/conversations' => "private_conversations#index", as: :private_conversations_home

  # Like Path
  post '/:likable_type/:likable_id/like', to: 'likes#create', as: :like
  delete '/:likable_type/likable_id/like', to: 'likes#destroy', as: :unlike

  # Feed (merged into root path)
  # get 'feed', to: 'feeds#show', as: :feed

  # Profiles -- this must be last
  get '/:username', to: 'profiles#show', as: :profile

  # we need to route people based on whether or not they are logged in
  root 'feeds#show', constraints: AuthenticationConstraint.new, as: :feed

  root 'static#home'

end
