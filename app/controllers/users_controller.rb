class UsersController < ApplicationController
  before_action :authorize, except: [:show]
  before_action :current_user, only: [:show]
  before_action :set_profile, only: [:show]

  layout 'without_sidenav'

  # GET /:username
  def show
    render('error', status: 404, layout: 'errors') and return unless @user

    @posts =
      @user.
      posts_made_and_received.
      readable_by_user(@current_user).
      most_recent_first.
      with_associations.
      paginate_with_anchor(:page => params[:page], :anchor => params[:anchor], :anchor_column => :created_at, :anchor_orientation => :less_than)
    @post = Post.new(:recipient => @user)
    @color_scheme = @user.color_scheme
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @user = User.viewable_by_user(@current_user).find_by_username(params[:username])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      #params.require(:user).permit(...)
    end
end
