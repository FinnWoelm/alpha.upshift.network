class FeedsController < ApplicationController
  before_action :authorize

  # GET /
  def show
    @posts =
      Post.
      from_and_to_network_of_user(@current_user).
      with_associations.
      most_recent_first.
      limit(30)

    @post = Post.new(:recipient => @current_user)
  end
end
