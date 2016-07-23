module ApplicationHelper

  # renders a timestamp
  def render_timestamp timestamp
    return timestamp.strftime('%a, %B %e, %Y at %l:%M%P')
  end

  # renders the like action
  def like_action object
    render :partial => 'likes/like', locals: {object: object}
  end

  # renders the unlike action
  def unlike_action object
    render :partial => 'likes/unlike', locals: {object: object}
  end

end
