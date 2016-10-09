class Democracy::Community::DecisionsController < ApplicationController
  before_action :authorize
  before_action :set_community, only: [:index, :new, :create]
  before_action :set_decision, only: :show

  # GET /communities/ID/decisions
  def index
    @decisions = @community.decisions
  end

  # GET /decisions/ID
  def show
  end

  # GET /communities/ID/decisions/ID
  def new
    @decision = @community.decisions.build
  end

  # POST /communities/ID/decisions/
  def create
    @decision = @community.decisions.build(decision_params)
    @decision.author = current_user

    if @decision.save
      redirect_to decision_path(@decision)
    else
      render :new
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_community
      @community = Democracy::Community.find(params[:community_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_decision
      @decision = Democracy::Community::Decision.find(params[:id])
    end

    def decision_params
      params.require(:democracy_community_decision).permit(:title, :description, :ends_at)
    end

end
