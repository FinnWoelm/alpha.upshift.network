class PrivateMessagesController < ApplicationController
  before_action :authorize
  before_action :set_conversation_by_id


  # POST /conversation/:id/message/
  def create
    render('error', status: 404, layout: 'fluid_with_side_nav') and return unless @private_conversation

    @private_message = @private_conversation.messages.build(private_message_params)

    if @private_message.save
      redirect_to @private_conversation
    else
      get_recent_conversations
      @private_conversation.mark_read_for @current_user
      render "private_conversations/show", layout: "fullscreen"
    end
  end

  protected

    # sets the conversation by ID
    def set_conversation_by_id
      @private_conversation = @current_user.private_conversations.with_associations.find_by id: params[:private_conversation_id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def private_message_params
      params.require(:private_message).permit(:content).merge(:sender => @current_user)
    end

end
