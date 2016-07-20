class FriendshipsController < ApplicationController
  before_action :authorize
  before_action :set_friendship, only: [:destroy]

  # POST /friendship/:username
  def create
    friendship = Friendship.new(:acceptor => @current_user)
    friendship.initiator = User.find_by_username(params[:username])

    if friendship.save
      redirect_to profile_path(friendship.initiator), notice: "#{friendship.initiator.name} and you are  now friends"
    else
      redirect_to profile_path(friendship.initiator), notice: 'An error occurred sending the friend request'
    end
  end

  # DELETE /friendship/:username
  def destroy

    @friendship.destroy

    begin
      redirect_to :back, notice: "You have ended your friendship with #{@friend.name}."
    rescue ActionController::RedirectBackError
      redirect_to profile_path(@friend), notice: "You have ended your friendship with #{@friend.name}."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_friendship
      @friend = User.find_by_username(params[:username])
      @friendship = Friendship.find_friendship_between(@current_user, @friend)
    end

end
