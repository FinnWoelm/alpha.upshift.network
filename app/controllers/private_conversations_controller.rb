class PrivateConversationsController < ApplicationController
  before_action :authorize
  before_action :set_conversation, only: [:show, :update]
  before_action :set_recipient, only: [:show, :update], if: '@private_conversation'
  before_action :initialize_or_find_conversation, only: [:create, :update], unless: '@private_conversation'
  before_action :build_private_message, only: [:create, :update]

  # GET /conversations
  def index
    # Get the user's private conversations ordered by most recent,
    # include the most recent message
    @private_conversations =
      @current_user.
      private_conversations.
      most_recent_activity_first.
      includes(:participants).
      includes(:most_recent_message)
  end

  # GET /conversation/new
  def new
    @private_conversation = PrivateConversation.new
    @private_message = @private_conversation.messages.build
  end

  # POST /conversation/
  def create
    if @private_conversation.new_record?
      create_conversation and return
    else
      add_message_to_conversation and return
    end
  end

  # GET /conversation/:username
  def show
    render_404 and return unless @private_conversation

    @private_conversation.mark_read_for @current_user

    @private_message = @private_conversation.messages.build
  end

  # PATCH /conversation/:id
  def update
    if @private_conversation.new_record?
      create_conversation and return
    else
      add_message_to_conversation and return
    end
  end

  # DELETE /conversation/:id
  def destroy
    @private_conversation = @current_user.private_conversations.find_by id: params[:id]
    @private_conversation.destroy
    redirect_to private_conversations_home_path, notice: 'Conversation was successfully deleted.'
  end

  protected

    # creates a new conversation
    def create_conversation
      if @private_conversation.save
        redirect_to @private_conversation
      else
        render :new
      end
    end

    # adds a message to an existing conversation
    def add_message_to_conversation
      if @private_conversation.save
        redirect_to @private_conversation
      else
        ActiveRecord::Associations::Preloader.new.preload(
          @private_conversation, :messages)
        ActiveRecord::Associations::Preloader.new.preload(
          @private_conversation, :participants)
        render :show
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_conversation

      username_format = /^[a-zA-Z0-9_]+$/

      # if the ID matches this format, then we are dealing with a username
      # and we want to set conversation by username
      if params[:id].match(username_format)
        set_conversation_by_recipient_username
      else
        set_conversation_by_id
      end
    end

    # sets the conversation by username
    def set_conversation_by_recipient_username
      @conversation_partner = User.readonly.find_by_username(params[:id])
      @private_conversation = PrivateConversation.with_associations.find_conversations_between([@current_user, @conversation_partner]).first if @conversation_partner.present?
    end

    # sets the conversation by ID
    def set_conversation_by_id
      @private_conversation = @current_user.private_conversations.with_associations.find_by id: params[:id]
    end

    # sets the recipient on the basis of the current user
    def set_recipient
      @private_conversation.recipient =
        @private_conversation.participants_other_than(@current_user).first
    end

    # initializes or finds a conversation from the params posted
    def initialize_or_find_conversation
      # create a new private conversation
      @private_conversation ||= PrivateConversation.new(private_conversation_params)

      # try to find an existing conversation
      if @private_conversation.new_record? and @private_conversation.recipient.is_a?(User)
        @private_conversation =
          PrivateConversation.find_conversations_between([
            @private_conversation.sender, @private_conversation.recipient
          ]).first || @private_conversation
      end
    end

    # builds a private message from the params submitted
    def build_private_message
      @private_message =
        @private_conversation.messages.build(private_message_params)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def private_conversation_params
      params.require(:private_conversation).
        permit(:recipient).
        merge(:sender => @current_user)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def private_message_params
      params.require(:private_conversation).
        permit(messages: [:content]).
        fetch(:messages).
        merge(:sender => @current_user)
    end

end
