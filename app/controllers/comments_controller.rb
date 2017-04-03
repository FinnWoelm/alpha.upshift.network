class CommentsController < ApplicationController
  before_action :authorize
  before_action :validate_that_commentable_type_is_permitted, only: :create
  before_action :set_commentable_object, only: :create
  before_action :set_comment, only: [:destroy]

  # POST /object/:object_id/comment/:id
  def create

    @comment = @object.comments.new(comment_params)

    if @comment.save
      redirect_back fallback_location: shallow_path_to(@object), notice: 'Comment was successfully added.'
    else
      ### okay, saving failed, let's show the object instead

      # set the variable
      instance_variable_set "@#{@object.model_name.to_s.downcase.split('::').last}", @object.class.with_associations.find(params[:commentable_id])

      # check if @object exists
      render(
        "#{params[:commentable_type].to_s.downcase}/error",
        status: 404,
        layout: 'errors'
      ) and return unless @object and @object.readable_by?(@current_user)

      # render object
      flash.now[:notice] = 'There was an error saving your comment. Please try again.'
      render "#{@object.model_name.to_s.downcase.gsub('::', '/')}s/show"
    end
  end

  # DELETE /object/:object_id/comment/:id
  def destroy
    @comment.destroy
    redirect_to shallow_path_to(@comment.commentable), notice: 'Comment was successfully removed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commentable_object
      object_class = params[:commentable_type].constantize
      @object = object_class.find params[:commentable_id]
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
      raise ActionController::UnpermittedParameters.new([:commentable_type]) unless permitted_types.include?(params[:commentable_type])
    end
end
