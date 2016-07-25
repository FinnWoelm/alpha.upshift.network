class PrivateConversationsController < ApplicationController
  before_action :authorize
  before_action :set_conversation_by_id, only: [:show, :destroy]
  before_action :set_conversation_by_recipient_username, only: :show

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
    @private_conversation = PrivateConversation.new
  end

  # POST /conversation/
  def create
  end

  # GET /conversation/:username
  def show
    render_404 and return unless @private_conversation
  end

  # DELETE /conversation/:id
  def destroy
    @private_conversation.destroy
    redirect_to private_conversations_home_path, notice: 'Conversation was successfully deleted.'
  end

  protected
    # Use callbacks to share common setup or constraints between actions.
    def set_conversation_by_recipient_username
      # return if we already have loaded a private_conversation by ID
      return if @private_conversation

      @conversation_partner = User.find_by_username(params[:id])
      @private_conversation = PrivateConversation.find_conversation_between([@current_user, @conversation_partner]).first if @conversation_partner
    end

    def set_conversation_by_id
      @private_conversation = @current_user.private_conversations.find_by id: params[:id]
    end

end
