module ApplicationHelper

  # renders a timestamp
  def render_timestamp timestamp
    "#{time_ago_in_words timestamp} ago"
  end

  # renders the like action
  def like_action object
    render :partial => 'likes/like', locals: {object: object}
  end

  # renders the unlike action
  def unlike_action object
    render :partial => 'likes/unlike', locals: {object: object}
  end

  # renders a user's profile picture
  def profile_picture username
    require 'digest/md5'
    hash = Digest::MD5.hexdigest username.strip.downcase
    "https://www.gravatar.com/avatar/#{hash}?d=identicon"
  end

end
