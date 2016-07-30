class PrivateMessagesController < ApplicationController
  before_action :authorize

  # POST /message
  def create

    @private_message = PrivateMessage.new(private_message_params)
    @private_message.sender = @current_user

    # we have a conversation
    if @private_message.private_conversation_id

      # private_conversation_id is set: We have an existing conversation, let's
      # just try to save.
      if @private_message.save
        redirect_to private_conversation_path(@private_message.private_conversation_id) and return
      else
        # okay, saving failed. If the conversation no longer exists, let's try
        # to recreate it from the recipient
        if not PrivateConversation.exists?(@private_message.private_conversation_id)
          @private_message.build_conversation(
            :sender => @private_message.sender,
            :recipient => @private_message.recipient)
        end
      end

    # no conversation set yet
    else

      # private_conversation_id is not set: We (probably) do not have an
      # existing conversation

      # let's set the recipient
      @recipient = @private_message.recipient

      # let's see if we do have a conversation between sender and recipient
      if @recipient.present?
        @private_message.conversation =
          PrivateConversation.find_conversations_between([
            @private_message.sender,
            @private_message.recipient
          ]).first
      end

      # did we find anything?
      if not @private_message.conversation.present?
        @private_message.build_conversation(
          :sender => @private_message.sender,
          :recipient => @private_message.recipient)
      end

    end

    # last but not least: let's try to save this whole thing!
    if @private_message.save
      redirect_to @private_message.conversation
    else
      @private_conversation = @private_message.conversation

      # if the conversation is not a new record (i.e. we're just having an
      # error related to message content)
      if not @private_conversation.new_record?
        # explicitly preload
        ActiveRecord::Associations::Preloader.new.preload(
          @private_conversation, :messages)
        render 'private_conversations/show'

      # if the conversation does not exist (or no longer exists)
      elsif @private_conversation.new_record?
        render 'private_conversations/new'

      # this should not be necessary, but just to be save
      else
        redirect_to private_conversations_home_path,
          notice: "There was an error sending your message."
      end

    end

  end

  protected
    # Never trust parameters from the scary internet, only allow the white list through.
    def private_message_params
      params.require(:private_message).permit(:content, :private_conversation_id, :recipient)
    end

end
