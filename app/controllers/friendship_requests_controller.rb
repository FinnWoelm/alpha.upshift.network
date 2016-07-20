class FriendshipRequestsController < ApplicationController
  before_action :authorize
  before_action :set_friendship_request, only: [:destroy]

  # GET /friend-requests
  def index
    @friendship_requests = @current_user.friendship_requests_received.includes(:sender)
  end

  # POST /friendship-request/:username
  def create
    friendship_request = FriendshipRequest.new(:sender => @current_user)
    friendship_request.recipient = User.includes(:profile).find_by_username(params[:username])

    if friendship_request.save
      redirect_to profile_path(friendship_request.recipient), notice: 'Friendship request was successfully sent.'
    else
      redirect_to profile_path(friendship_request.recipient), notice: 'An error occurred sending the friend request.'
    end
  end

  # DELETE /friendship-request/:username
  def destroy
    @friendship_request.destroy
    redirect_back fallback_location: friendship_requests_received_path, notice: 'Friendship request was successfully deleted'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_friendship_request
      sender = User.find_by_username(params[:username])
      @friendship_request = @current_user.friendship_requests_received.where(:sender => sender).first
    end
end
