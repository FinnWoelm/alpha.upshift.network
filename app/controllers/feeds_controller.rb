class FeedsController < ApplicationController
  before_action :authorize

  # GET /
  def show

    @posts = Post.none
    # get friends

    # get posts with comments and content that user has liked
  end
end
