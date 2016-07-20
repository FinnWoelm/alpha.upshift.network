class FriendshipsController < ApplicationController
  before_action :authorize

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

  def destroy
  end
end
