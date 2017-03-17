class PrivateConversationsController < ApplicationController
  include PrivateConversationsHelper

  before_action :authorize
  before_action :set_conversation, only: :show
  before_action :get_recent_conversations_for_sidenav, only: [:show, :new]

  layout Proc.new{
    if ['show'].include?(action_name)
      'fullscreen'
    elsif ['index', 'new', 'create'].include?(action_name)
      'fluid_with_side_nav'
    end
  }

  # GET /conversations
  def index
    @private_conversations =
      PrivateConversation.
      for_user(@current_user).
      with_unread_message_count_for(@current_user)
  end

  # GET /conversations/refresh
  def refresh
    @private_conversations =
      PrivateConversation.
      for_user(@current_user).
      with_unread_message_count_for(@current_user).
      with_params(
        updated_after: params[:updated_after],
        order: params[:order]
      ).
      limit(10)

    # render nothing if we have no private conversations
    (render js: '' and return) if @private_conversations.first.nil?

    @render_previews_in_sidenav = params[:sidenav] == "true"
  end

  # GET /conversation/new
  def new
    @private_conversation = PrivateConversation.new
    @private_message = @private_conversation.messages.build
  end

  # POST /conversation/
  def create

    @private_conversation = PrivateConversation.new(private_conversation_params)

    # try to find an existing conversation
    if @private_conversation.recipient.is_a?(User)
      @existing_conversation =
        PrivateConversation.find_conversations_between([
          @private_conversation.sender, @private_conversation.recipient
        ]).first
      redirect_to link_to_private_conversation @existing_conversation and return if @existing_conversation
    end

    if @private_conversation.save
      redirect_to link_to_private_conversation @private_conversation
    else
      get_recent_conversations_for_sidenav
      render :new
    end

  end

  # GET /conversation/:username
  def show
    render('error', status: 404, layout: 'fluid_with_side_nav') and return unless @private_conversation

    @private_conversation.mark_read_for @current_user

    @private_messages = @private_conversation.messages.paginate_with_anchor(:page => params[:page], :anchor => params[:anchor], :anchor_column => :id, :anchor_orientation => :less_than)
    @private_message = @private_conversation.messages.build
  end

  # DELETE /conversation/:id
  def destroy
    @private_conversation = @current_user.private_conversations.find_by id: params[:id]
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
      @private_conversation = PrivateConversation.with_associations.find_conversations_between([@current_user, @conversation_partner]).first if @conversation_partner.present?
    end

    # sets the conversation by ID
    def set_conversation_by_id
      @private_conversation = @current_user.private_conversations.with_associations.find_by id: params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def private_conversation_params
      params.require(:private_conversation).
        permit(:recipient).
        merge(:sender => @current_user)
    end

end
