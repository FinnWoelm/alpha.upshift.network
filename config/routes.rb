class AuthenticationConstraint

  # Signed-in users only
  def matches?(request)
    request.session[:user_id].present?
  end
end

Rails.application.routes.draw do

  # Magic Lamp for using views in JS specs
  mount MagicLamp::Genie, at: "/magic_lamp" if defined?(MagicLamp)

  # Errors
  match "/404", :to => "errors#not_found", :via => :all
  match "/422", :to => "errors#unacceptable", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  # External
  resources :pending_newsletter_subscriptions, only: :create do
    get 'confirm', on: :collection
  end

  # Registrations
  resource :signup, controller: 'registrations', as: 'registration', only: [:new, :create], path_names: { new: '' } do
    get 'confirm', on: :collection
    get 'confirmation_reminder', on: :collection
    post 'resend_confirmation', on: :collection, :constraints => { :format => 'js' }
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
  resources :posts, only: [:new, :create, :show, :destroy], :path => "post"

  # Private Conversations & Messages
  resources :private_conversations, only: [:new, :create, :show, :update, :destroy], :path => "conversation" do
    resources :private_messages, only: [:create], :path => "message"
    resources :private_messages, only: [], :path => "messages" do
      get 'refresh', on: :collection, constraints: lambda { |req| req.format == :js }
    end
  end
  get '/conversations' => "private_conversations#index", as: :private_conversations_home

  # Like Path
  post '/:likable_type/:likable_id/like', to: 'likes#create', as: :like
  delete '/:likable_type/likable_id/like', to: 'likes#destroy', as: :unlike

  # Comment Path
  post '/:commentable_type/:commentable_id/comment', to: 'comments#create', as: :comment
  delete '/comments/:id', to: 'comments#destroy', as: :delete_comment

  # Votes Path
  resources :votes, only: [:create, :update, :destroy], :path => "vote"

  # Feed (merged into root path)
  # get 'feed', to: 'feeds#show', as: :feed

  ### Democracy
  scope module: 'democracy', shallow: true do
    resources :communities, only: [:index, :show], module: 'community' do
      resources :decisions, only: [:index, :show, :new, :create]
    end
  end

  # Profiles -- this must be last
  get '/:username', to: 'profiles#show', as: :profile

  # we need to route people based on whether or not they are logged in
  root 'feeds#show', constraints: AuthenticationConstraint.new, as: :feed

  root 'static#home'

end
