class FriendshipsController < ApplicationController
  before_action :authorize
  before_action :set_friendship, only: [:destroy]

  # POST /friendship/:username
  def create
    friendship = Friendship.new(:acceptor => @current_user)
    friendship.initiator = User.find_by_username(params[:username])

    if friendship.save
      redirect_to friendship.initiator, notice: "You and #{friendship.initiator.name} are now friends"
    else
      redirect_to friendship.initiator, notice: 'An error occurred sending the friend request'
    end
  end

  # DELETE /friendship/:username
  def destroy
    @friendship.destroy
    redirect_back fallback_location: @friend, notice: "You have ended your friendship with #{@friend.name}."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_friendship
      @friend = User.find_by_username(params[:username])
      @friendship = Friendship.find_friendships_between(@current_user, @friend).first
    end

end
