class PrivateMessagesController < ApplicationController
  include PrivateConversationsHelper

  before_action :authorize
  before_action :set_conversation_by_id

  # POST /conversation/:private_conversation_id/message/
  def create
    render('error', status: 404, layout: 'errors') and return unless @private_conversation

    @private_message = @private_conversation.messages.build(private_message_params)

    if @private_message.save
      respond_to do |format|
        format.html {
          redirect_to link_to_private_conversation @private_conversation
        }
        format.js { }
      end
    else
      respond_to do |format|
        format.html {
          get_recent_conversations_for_sidenav
          @private_conversation.mark_read_for @current_user
          render "private_conversations/show", layout: "fullscreen"
        }
        format.js {
          render :error
        }
      end
    end
  end

  # GET /conversation/:private_conversation_id/messages/refresh.js
  def refresh
    render(:error, status: 404, layout: 'errors') and return unless @private_conversation

    @private_messages =
      @private_conversation.messages.
      where("private_messages.id > ?", params[:last_message_id]).
      order(id: :asc)

    @private_conversation.mark_read_for @current_user

    (render js: '' and return) if @private_messages.none?
  end

  protected

    # sets the conversation by ID
    def set_conversation_by_id
      respond_to do |format|
        format.html {
          @private_conversation = @current_user.private_conversations.with_associations.find_by id: params[:private_conversation_id]
        }
        format.js {
          @private_conversation = @current_user.private_conversations.includes(:participants).find_by id: params[:private_conversation_id]
        }
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def private_message_params
      params.require(:private_message).permit(:content).merge(:sender => @current_user)
    end

end
