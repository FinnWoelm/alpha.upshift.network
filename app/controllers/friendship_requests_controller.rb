class FriendshipRequestsController < ApplicationController
  before_action :authorize
  before_action :set_friendship_request, only: [:destroy]

  # GET /friend-requests
  def index
    @friendship_requests =
      @current_user.friendship_requests_received.order(id: :desc).includes(:sender)
  end

  # POST /friendship-request/:username
  def create
    @friendship_request =
      FriendshipRequest.new(
        friendship_request_params.merge(:sender => @current_user))

    # attempt to save
    @friendship_request.save

    if @friendship_request.errors[:recipient_username].count == 0

      # redirect to recipient if recipient is visible
      if @friendship_request.recipient.present? and @friendship_request.recipient.viewable_by?(@current_user)
        redirect_to(@friendship_request.recipient, notice: 'Friend request was successfully sent.') and return
      end

      # friend request was sent successfully
      @success = true
      @user_added = @friendship_request.recipient_username
      @friendship_request = nil
    end

    @friendship_requests = @current_user.friendship_requests_received.includes(:sender)
    render 'index'
  end

  # DELETE /friendship-request/:username
  def destroy
    @friendship_request.destroy
    redirect_back fallback_location: friendship_requests_path, notice: 'Friend request was successfully deleted'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_friendship_request
      other_user = User.find_by_username(params[:username])
      @friendship_request =
        FriendshipRequest.
        find_friendship_requests_between(@current_user, other_user).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def friendship_request_params
      params.require(:friendship_request).permit(:recipient_username)
    end
end
