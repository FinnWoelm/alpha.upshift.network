module ProfilesHelper
  def friendship_actions

    # do not show anything if user is not signed in
    return unless @current_user

    # do not show anything if user is on their own profile
    return if @profile.user.id == @current_user.id

    # if user has a friendship with this profile
    if @current_user.has_friendship_with?(@profile.user)
      render partial: "friendship/end_friendship_action", locals: { friend: @profile.user }

    # if user has sent a friend request to this profile
    elsif @current_user.has_sent_friend_request_to?(@profile.user)
      render partial: "friendship_requests/revoke_friendship_request_action", locals: { recipient: @profile.user }

    # if user has received a friend request from this profile
    elsif @current_user.has_received_friend_request_from?(@profile.user)
      render partial: "friendship_requests/respond_to_friend_request_actions", locals: { sender: @profile.user }

    # otherwise, just show the add friend button
    else
      render partial: "friendship_requests/add_friend_action", locals: { new_friend: @profile.user }
    end

  end

  # shows form to write new post
  def write_post_action

    # do not show anything unless user is logged in
    return unless @current_user

    render partial: 'posts/form', locals: {post: @post}

  end

  # shows a message that no posts have been written yet
  def no_posts_yet_message
    if @profile.user.id == @current_user.id
      return "You have not written any posts yet"
    else
      return "#{@profile.user.name} has not written any posts yet."
    end
  end
end
