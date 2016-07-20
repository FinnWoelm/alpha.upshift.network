module ProfilesHelper
  def add_friend_button

    # do not show add friend button if user is not signed in
    return unless @current_user

    # do not show add friend button if user is on their own profile
    return if @profile.user.id == @current_user.id

    # do not show add friend button if user has already sent a friend request
    return if @profile.user.has_received_friend_request_from(@current_user)

    # ok, we can show the add friend button
    render partial: "friendship_requests/new", locals: { new_friend: @profile.user }

  end
end
