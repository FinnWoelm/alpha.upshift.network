module LikesHelper

  # builds a unique ID based on likable object type and id
  def get_like_action_id like_action, likable_object
    "#{like_action.to_s}-#{likable_object.class.base_class.to_s.downcase}-#{likable_object.id}"
  end

  # renders the like action
  def like_action object, style, is_liked = true
    likes_without_user = object.likes_count || 0

    # if the object is currently being liked by user, subtract one like to get
    # the unliked state
    likes_without_user -= 1 if is_liked

    render(
      partial: "likes/#{style}",
      layout: "likes/wrapper",
      locals: {
        object: object,
        likes_without_user: likes_without_user,
        is_liked: is_liked,
        button_type: style
      }
    )
  end
end
