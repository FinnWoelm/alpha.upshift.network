MagicLamp.define(controller: StaticController) do

  fixture do
    @pending_newsletter_subscription = PendingNewsletterSubscription.new
    render :home
  end
end

MagicLamp.define(controller: PrivateConversationsController) do

  fixture do
    @current_user = FactoryGirl.create(:user)
    @private_conversation = FactoryGirl.create(:private_conversation, :sender => @current_user)
    @private_conversation.messages = FactoryGirl.create_list(:private_message, 20, :conversation => @private_conversation)
    @private_message = @private_conversation.messages.build
    render :show
  end

  fixture(name: 'side_navigation') do
    @current_user = FactoryGirl.create(:user)
    @private_conversations = FactoryGirl.create_list(:private_conversation, 5, :sender => @current_user).sort_by(&:updated_at).reverse
    render(partial: "shared/side_navigation/private_conversations", locals: {conversations: @private_conversations})
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

MagicLamp.define(controller: RegistrationsController) do

  fixture do
    @user = User.new
    render :new
  end
end
