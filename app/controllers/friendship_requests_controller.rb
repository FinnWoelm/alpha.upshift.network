class FriendshipRequestsController < ApplicationController
  before_action :authorize
  before_action :set_friendship_request, only: [:destroy]

  # GET /friendship_requests
  def index
    @friendship_requests = FriendshipRequest.all
  end

  # POST /friendship_requests
  def create
    @friendship_request = FriendshipRequest.new(:sender => @current_user)
    @friendship_request.recipient = User.includes(:profile).find_by_username(params[:username])

    if @friendship_request.save
      redirect_to profile_path(@friendship_request.recipient), notice: 'Friendship request was successfully sent.'
    else
      redirect_to profile_path(@friendship_request.recipient), notice: 'An error occurred sending the friend request.'
    end
  end

  # DELETE /friendship_requests/1
  def destroy
    @friendship_request.destroy
    redirect_to friendship_requests_url, notice: 'Friendship request was successfully deleted.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_friendship_request
      @friendship_request = FriendshipRequest.find(params[:id])
    end
end
