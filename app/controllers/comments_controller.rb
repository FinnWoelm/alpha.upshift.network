class CommentsController < ApplicationController
  before_action :authorize
  before_action :set_post
  before_action :set_comment, only: [:destroy]

  # POST /post/:post_id/comment/:id
  def create
    @comment = @post.comments.build(comment_params)
    @comment.author = @current_user

    if @comment.save
      redirect_back fallback_location: @post, notice: 'Comment was successfully added.'
    else
      render :controller => post, :action => show, notice: 'There was an error creating your comment. Please try again.'
    end
  end

  # DELETE /post/:post_id/comment/:id
  def destroy
    @comment.destroy
    redirect_to @comment.post, notice: 'Comment was successfully removed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find params[:post_id]
    end

    def set_comment
      @comment = Comment.includes(:post).find_by id: params[:id], post: @post
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:content)
    end
end
