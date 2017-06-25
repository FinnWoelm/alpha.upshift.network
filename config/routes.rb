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

  get '/colors/test', :to => "helpers/colors#test"

  # Accounts Path
  resource :account, only: [], :path => "settings" do
    get '/', action: 'edit', as: :edit
    match '/', action: 'update', as: :update, via: [:patch, :put]
  end
  resource :account, only: [] do
    match '/delete', action: 'destroy', as: :delete, via: [:post]
    match '/confirm_deletion', action: 'confirm_destroy', as: :confirm_delete, via: [:delete]
  end

  # Sessions
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  # FriendshipRequests
  resources :friendship_requests, only: [:index, :create], :path => "friend-requests"
  delete 'friendship-request/:username' => 'friendship_requests#destroy', as: :reject_friendship_request

  # Friendships
  post 'friendship/:username' => 'friendships#create', as: :accept_friendship_request
  delete 'friendship/:username' => 'friendships#destroy', as: :end_friendship

  # notifications
  resources :notifications, only: [:index] do
    post 'mark_seen', :action => :mark_seen
    post 'mark_all_seen', on: :collection, :action => :mark_all_seen
  end

  # Posts
  resources :posts, only: [:new, :create, :show, :destroy], :path => "post" do
    get '', on: :collection, :action => :new
  end

  # Private Conversations & Messages
  resources :private_conversations, only: [:new, :create, :show, :update, :destroy], :path => "conversation" do
    resources :private_messages, only: [:create], :path => "message"
    resources :private_messages, only: [], :path => "messages" do
      get 'refresh', on: :collection, constraints: lambda { |req| req.format == :js }
    end
  end
  get '/conversations' => "private_conversations#index", as: :private_conversations_home
  resources :private_conversations, only: [], :path => "conversations" do
    get 'refresh', on: :collection, constraints: lambda { |req| req.format == :js }
  end

  # Like Path
  post '/:likable_type/:likable_id/like', to: 'likes#create', as: :like
  delete '/:likable_type/likable_id/like', to: 'likes#destroy', as: :unlike

  # Comment Path
  post '/:commentable_type/:commentable_id/comment', to: 'comments#create', as: :comment
  delete '/comments/:id', to: 'comments#destroy', as: :delete_comment

  # Search Path
  get 'search', to: 'search#search', as: :search

  # User Path
  get '/profile/edit', to: 'users#edit', as: :edit_user
  match '/profile/edit', to: 'users#update', via: [:patch, :put]

  # Votes Path
  resources :votes, only: [:create, :update, :destroy], :path => "vote"

  # Feed (merged into root path)
  # get 'feed', to: 'feeds#show', as: :feed

  ### Democracy
  ### Disabled while we're focusing on completion of MVP
  # scope module: 'democracy', shallow: true do
  #   resources :communities, only: [:index, :show], module: 'community' do
  #     resources :decisions, only: [:index, :show, :new, :create]
  #   end
  # end

  # User profiles -- this must be last
  get '/:username', to: 'users#show', as: :user,
    constraints: { :username => Username.regex(:anchors => false) }

  # Profile Pictures
  scope module: 'user' do
    get '/:username/:attachment/:size', to: 'attachments#show',
      constraints: {
        :username => Username.regex(:anchors => false),
        :attachment => "profile_picture",
        :size => /(medium)|(large)/,
        :format => "jpg"
      }
    get '/:username/:attachment/:size', to: 'attachments#show',
      constraints: {
        :username => Username.regex(:anchors => false),
        :attachment => "profile_banner",
        :size => "original",
        :format => "jpg"
      }
  end

  # we need to route people based on whether or not they are logged in
  root 'feeds#show', constraints: AuthenticationConstraint.new, as: :feed

  root 'static#home'

end
