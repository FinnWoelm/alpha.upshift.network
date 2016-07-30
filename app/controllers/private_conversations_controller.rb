class PrivateConversationsController < ApplicationController
  before_action :authorize
  before_action :set_conversation, only: [:show, :destroy]

  # GET /conversations
  def index
    # Get the user's private conversations ordered by most recent,
    # include the most recent message
    @private_conversations =
      @current_user.
      private_conversations.
      includes(:most_recent_message)
  end

  # GET /conversation/new
  def new
    conversation = PrivateConversation.new(:sender => @current_user)
    @private_message = PrivateMessage.new(:sender => @current_user, :conversation => conversation)
  end

  # GET /conversation/:username
  def show
    render_404 and return unless @private_conversation

    @private_conversation.mark_read_for @current_user

    @private_message =
      PrivateMessage.new(
        :sender => @current_user,
        :recipient => @private_conversation.participants_other_than(@current_user).first,
        :conversation => @private_conversation)
  end

  # DELETE /conversation/:id
  def destroy
    @private_conversation.destroy
    redirect_to private_conversations_home_path, notice: 'Conversation was successfully deleted.'
  end

  protected

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
      @private_conversation = PrivateConversation.includes(:messages).find_conversations_between([@current_user, @conversation_partner]).first if @conversation_partner.present?
    end

    # sets the conversation by ID
    def set_conversation_by_id
      @private_conversation = @current_user.private_conversations.find_by id: params[:id]
    end

end
