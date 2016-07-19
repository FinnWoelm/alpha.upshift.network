class FriendshipRequestsController < ApplicationController
  before_action :authorize
  before_action :set_friendship_request, only: [:destroy]

  # GET /friendship_requests
  def index
    @friendship_requests = FriendshipRequest.all
  end

  # POST /friendship_requests
  def create
    @friendship_request = FriendshipRequest.new(friendship_request_params)

    if @friendship_request.save
      redirect_to @friendship_request, notice: 'Friendship request was successfully sent.'
    else
      render :new
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def friendship_request_params
      params.require(:friendship_request).permit(:sender_id, :recipient_id)
    end
end
