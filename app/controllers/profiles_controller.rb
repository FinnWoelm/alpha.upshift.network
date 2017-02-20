class ProfilesController < ApplicationController
  before_action :authorize, except: [:show]
  before_action :current_user, only: [:show]
  before_action :set_profile, only: [:show]

  # GET /:username
  def show
    render('error', status: 404, layout: 'errors') and return unless @profile and @profile.viewable_by?(@current_user)

    @posts = @user.posts.most_recent_first.with_associations
    @post = Post.new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @user = User.includes(:profile).find_by_username(params[:username])
      @profile = @user.profile if @user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:user_id, :visibility)
    end
end
