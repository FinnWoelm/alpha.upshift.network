class Democracy::CommunitiesController < ApplicationController
  before_action :authorize
  before_action :set_community, only: :show

  layout "with_sidenav"

  # GET /communities
  def index
    @communities = Democracy::Community.all
  end

  # GET /communities/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_community
      @community = Democracy::Community.find(params[:id])
    end

end
