class CommentsController < ApplicationController
  before_action :authorize
  before_action :validate_that_commentable_type_is_permitted, only: [:create]
  before_action :set_commentable_object, only: [:create]
  before_action :set_comment, only: [:destroy]

  # POST /post/:post_id/comment/:id
  def create

    if @object.comments.create(comment_params)
      redirect_back fallback_location: @object, notice: 'Comment was successfully added.'
    else
      redirect_back fallback_location: @object, notice: 'There was an error creating your comment. Please try again.'
    end
  end

  # DELETE /post/:post_id/comment/:id
  def destroy
    @comment.destroy
    redirect_to @comment.commentable, notice: 'Comment was successfully removed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commentable_object
      object_class = params[:comment][:commentable_type].capitalize.constantize
      @object = object_class.find params[:comment][:commentable_id]
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find_by id: params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:content).merge(:author => @current_user)
    end

    # Validate that this object can be commented on
    def validate_that_commentable_type_is_permitted
      permitted_types = Comment.commentable_types
      raise ActionController::UnpermittedParameters.new([:commentable_type]) unless permitted_types.include?(params[:comment][:commentable_type])
    end
end
