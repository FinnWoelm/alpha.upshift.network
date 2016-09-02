class LikesController < ApplicationController
  before_action :authorize
  before_action :validate_that_likable_type_is_permitted
  before_action :set_likable_object, only: [:create]
  before_action :set_like, only: [:destroy]

  # POST /:likable_type/:likable_id/like
  def create
    if @object.likes.create(:liker => @current_user)
      redirect_back fallback_location: root_path, notice: "Successfully liked #{params[:likable_type].downcase}."
    else
      redirect_back fallback_location: root_path, notice: "Error liking #{params[:likable_type].downcase}."
    end
  end

  # DELETE /:likable_type/:likable_id/like
  def destroy
    @like.destroy
    redirect_back fallback_location: root_path, notice: "Successfully unliked #{params[:likable_type].downcase}."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_likable_object
      object_class = params[:likable_type].capitalize.constantize
      @object = object_class.find params[:likable_id]
    end

    def set_like
      @like = Like.find_by likable_id: params[:likable_id], likable_type: params[:likable_type], liker: @current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def validate_that_likable_type_is_permitted
      permitted_types = Like.likable_types
      raise ActionController::UnpermittedParameters.new([:likable_type]) unless permitted_types.include?(params[:likable_type])
    end
end
