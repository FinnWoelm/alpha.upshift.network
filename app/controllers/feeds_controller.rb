class FeedsController < ApplicationController
  before_action :authorize

  # GET /
  def show
    @posts =
      Post.
      from_and_to_network_of_user(@current_user).
      with_associations.
      most_recent_first.
      paginate_with_anchor(
        :page => params[:page],
        :per_page => Rails.configuration.x.feed.items_per_page,
        :anchor => params[:anchor] || Time.zone.now,
        :anchor_column => :created_at,
        :anchor_orientation => :less_than
      )

    @post = Post.new(:recipient => @current_user)
  end
end
