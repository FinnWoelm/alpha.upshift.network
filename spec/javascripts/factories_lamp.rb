MagicLamp.define(controller: StaticController) do

  fixture do
    @pending_newsletter_subscription = PendingNewsletterSubscription.new
    render :home
  end
end

MagicLamp.define(controller: UsersController) do

  fixture do
    @user = FactoryGirl.create(:user)
    render :edit
  end
end

MagicLamp.define(controller: NotificationsController) do

  fixture do
    @current_user = FactoryGirl.create(:user)
    FactoryGirl.create_list(:post, 3, :recipient => @current_user)
    @notifications =
      Notification.
      preload(:notifier).
      preload(actions: [:actor]).
      for_user(@current_user).
      paginate(:page => 1)
    render :index
  end
end

MagicLamp.define(controller: PrivateConversationsController) do

  fixture do
    @current_user = FactoryGirl.create(:user)
    @private_conversation = FactoryGirl.create(:private_conversation, :sender => @current_user)
    FactoryGirl.create_list(:private_message, 20, :conversation => @private_conversation)
    @private_messages = @private_conversation.messages.paginate_with_anchor(:page => nil, :anchor => nil, :anchor_column => :id, :anchor_orientation => :less_than)
    @private_message = @private_conversation.messages.build
    render :show
  end

  fixture(name: 'side_navigation') do
    @current_user = FactoryGirl.create(:user)
    @private_conversations = FactoryGirl.create_list(:private_conversation, 5, :sender => @current_user).sort_by(&:updated_at).reverse
    render(partial: "shared/side_navigation/private_conversations", locals: {conversations: @private_conversations})
  end

  fixture(name: 'refresh') do
    @current_user = FactoryGirl.create(:user)
    @private_conversations = FactoryGirl.create_list(:private_conversation, 5, :sender => @current_user)
    @private_conversations.each do |c|
      FactoryGirl.create(:private_message, :conversation => c)
    end
    render 'refresh.js'
  end

  fixture(name: 'index_js') do
    @current_user = FactoryGirl.create(:user)
    FactoryGirl.create_list(:private_conversation, 5, :sender => @current_user)
    @private_conversations =
      PrivateConversation.
      for_user(@current_user).
      with_unread_message_count_for(@current_user).
      paginate_with_anchor(:page => nil, :anchor => nil, :anchor_column => :id, :anchor_orientation => :less_than)
    render 'index.js'
  end

  fixture do
    @current_user = FactoryGirl.create(:user)
    FactoryGirl.create_list(:private_conversation, 5, :sender => @current_user)
    @private_conversations =
      PrivateConversation.
      for_user(@current_user).
      with_unread_message_count_for(@current_user).
      paginate_with_anchor(:page => nil, :anchor => nil, :anchor_column => :id, :anchor_orientation => :less_than)
    render :index
  end
end

MagicLamp.define(controller: PrivateMessagesController) do
  fixture do
    @current_user = FactoryGirl.create(:user)
    @private_conversation = FactoryGirl.create(:private_conversation, :sender => @current_user)
    @private_messages = FactoryGirl.create_list(:private_message, 3, :conversation => @private_conversation)
    render :refresh
  end

  fixture do
    @current_user = FactoryGirl.create(:user)
    @private_conversation = FactoryGirl.create(:private_conversation, :sender => @current_user)
    @private_message = FactoryGirl.create(:private_message, :conversation => @private_conversation)
    render :create
  end
end
