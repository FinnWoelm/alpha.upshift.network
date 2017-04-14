class PostsController < ApplicationController
  before_action :authorize, except: [:show]
  before_action :current_user, only: [:show]
  before_action :set_post_with_assocations, only: [:show]
  before_action :set_post_without_associations, only: [:destroy]

  layout Proc.new{
    if @current_user
      'application'
    else
      'without_sidenav'
    end
  }

  # GET /post/1
  def show
    render('error', status: 404, layout: 'errors') and return unless @post
  end

  # GET /post/new
  def new
    @post = Post.new(:profile_owner => @current_user)
  end


  # POST /post
  def create
    @post = Post.new(post_params)
    @post.author = @current_user

    if @post.save
      referrer = Rails.application.routes.recognize_path(request.referrer)
      notice = 'Post was successfully created'

      # do not redirect_back if we're coming from post#new
      if referrer[:controller] == "posts"
        redirect_to @post, notice: notice
      else
        redirect_back fallback_location: @post, notice: notice
      end
    else
      render :new
    end
  end

  # DELETE /post/1
  def destroy
    @post.destroy
    redirect_to profile_path(@current_user), notice: 'Post was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post_without_associations
      @post = Post.find_by_id(params[:id])
    end

    def set_post_with_assocations
      @post = Post.readable_by_user(@current_user).with_associations.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:content, :profile_owner)
    end
end
