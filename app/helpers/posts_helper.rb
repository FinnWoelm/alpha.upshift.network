module PostsHelper

  def write_comment_for_post_action post
    # do not show anything unless user is signed in
    return unless @current_user

    @comment ||= Comment.new(:post => post)
    render partial: 'comments/form', locals: {comment: @comment}
  end

end
