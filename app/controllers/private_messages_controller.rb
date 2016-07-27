class PrivateMessagesController < ApplicationController
  before_action :authorize
  #before_action :set_conversation, only: [:create]

  # POST /conversation/:conversation_id/message
  def create

    @private_message = PrivateMessage.new(private_message_params)
    @private_message.sender = @current_user

    if @private_message.save
      redirect_to @private_message.conversation
    else
      set_conversation
      @private_message.conversation = @private_conversation

      # private conversation still exists -> show conversation
      if @private_conversation
        render 'private_conversations/show',
          notice: 'There was an error sending your private message. Please try again.'

      # the private conversation no longer exists -> take user back to inbox
      else
        redirect_to private_conversations_home_path,
          notice: 'There was an error sending your private message. Please try again.'
      end

    end

  end

  protected
    # Use callbacks to share common setup or constraints between actions.
    def set_conversation

      username_format = /^[a-zA-Z0-9_]+$/

      # if the ID matches this format, then we are dealing with a username
      # and we want to set conversation by username
      if params[:private_conversation_id].match(username_format)
        set_conversation_by_recipient_username
      else
        set_conversation_by_id
      end

    end

    # sets the conversation by username
    def set_conversation_by_recipient_username
      @conversation_partner = User.readonly.find_by_username(params[:private_conversation_id])
      @private_conversation = PrivateConversation.includes(:messages).find_conversation_between([@current_user, @conversation_partner]).first if @conversation_partner
    end

    # sets the conversation by ID
    def set_conversation_by_id
      @private_conversation = @current_user.private_conversations.find_by id: params[:private_conversation_id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def private_message_params
      params.require(:private_message).permit(:content, :private_conversation_id)
    end

end
