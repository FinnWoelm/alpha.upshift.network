class ProfilesController < ApplicationController
  before_action :authorize, except: [:show]
  before_action :current_user, only: [:show]
  before_action :set_profile, only: [:show]

  # GET /:username
  def show
    render_404 and return unless @profile
    render_404 and return unless @profile.can_be_seen_by?(@current_user)

    @posts = @user.posts.includes(:author)
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
