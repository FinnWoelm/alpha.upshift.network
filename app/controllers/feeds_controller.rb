class FeedsController < ApplicationController
  before_action :authorize

  layout 'with_sidenav'

  # GET /
  def show

    # get friends
    friend_ids = current_user.friends.map {|f| f.id}
    friend_ids << current_user.id

    # get 30 most recent posts
    @posts =
      Post.with_associations.most_recent_first.
        where(:author_id => friend_ids).limit(30)

    # create new post
    @post = Post.new

  end
end
