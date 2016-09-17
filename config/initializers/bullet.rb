if defined? Bullet

  # We need to eager load comments for each post. This will cause Bullet to
  # raise alarm if the number of comments is zero or one. The only way to
  # selectively eager load, when comments_count > 1, would be using a counter
  # cache. But that seems inefficient for the task at hand, so we will just
  # ignore these warnings.
  Bullet.add_whitelist :type => :unused_eager_loading,
    :class_name => "Post",
    :association => :comments

  # Similar story for post likes. When these are 0 or 1, Bullet raises an error.
  # But we need the likes eager loaded for any scenario with 1+ likes.
  Bullet.add_whitelist :type => :unused_eager_loading,
    :class_name => "Post",
    :association => :likes

  # We need to eager load a comment's likes, so that we can determine whether
  # the object can or cannot be liked by a user. This however is causing Bullet
  # to erraneously report "unused eager loading". If the eager loading is
  # removed, then Bullet says "N+1 Query detected" and suggests eager loading
  # likes. Probably a bug.
  Bullet.add_whitelist :type => :unused_eager_loading,
    :class_name => "Comment",
    :association => :likes

  # We need to eager load messages for each conversation. This will cause Bullet
  # to raise alarm if the number of messages is zero or one. The only way to
  # selectively eager load, when messages_count > 1, would be using a counter
  # cache. But that seems inefficient for the task at hand, so we will just
  # ignore these warnings.
  Bullet.add_whitelist :type => :unused_eager_loading,
    :class_name => "PrivateConversation",
    :association => :messages

  # We need to eager load participants for each conversation (to get the name).
  # This will cause Bullet to raise alarm if the number of participants is
  # zero or one.
  Bullet.add_whitelist :type => :unused_eager_loading,
    :class_name => "PrivateConversation",
    :association => :participants
  Bullet.add_whitelist :type => :unused_eager_loading,
    :class_name => "ParticipantshipInPrivateConversation",
    :association => :participant


  if Rails.env.development?
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.alert = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  elsif Rails.env.test?
    Bullet.raise = true
  end
end
