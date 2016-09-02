class CommentsController < ApplicationController
  before_action :authorize
  before_action :set_comment, only: [:destroy]

  # POST /post/:post_id/comment/:id
  def create
    @comment = Comment.new(comment_params)
    @comment.author = @current_user

    if @comment.save
      redirect_back fallback_location: post_path(@comment.post_id), notice: 'Comment was successfully added.'
    else
      # we're going to render, let's get the post with associations
      @post = Post.with_associations.find params[:post_id]
      @comment.post = @post
      render 'posts/show', notice: 'There was an error creating your comment. Please try again.'
    end
  end

  # DELETE /post/:post_id/comment/:id
  def destroy
    @comment.destroy
    redirect_to post_path(@comment.post_id), notice: 'Comment was successfully removed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find_by id: params[:id], post_id: params[:post_id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:content, :post_id)
    end
end
