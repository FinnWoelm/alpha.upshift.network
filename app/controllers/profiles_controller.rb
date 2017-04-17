class ProfilesController < ApplicationController
  before_action :authorize, except: [:show]
  before_action :current_user, only: [:show]
  before_action :set_profile, only: [:show]

  layout 'without_sidenav'

  # GET /:username
  def show
    render('error', status: 404, layout: 'errors') and return unless @profile

    @posts =
      @user.
      posts_made_and_received.
      readable_by_user(@current_user).
      most_recent_first.
      with_associations
    @post = Post.new(:profile_owner => @user)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @user = User.includes(:profile).viewable_by_user(@current_user).find_by_username(params[:username])
      @profile = @user.profile if @user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:user_id, :visibility)
    end
end
