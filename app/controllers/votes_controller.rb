class VotesController < ApplicationController
  before_action :authorize
  before_action :set_votable_object, only: :create
  before_action :set_vote, only: [:update, :destroy]

  def create
    if @object.votes.create(vote_params)
      redirect_back fallback_location: shallow_path_to(@object), notice: 'Vote successfully cast.'
    else
      redirect_back fallback_location: shallow_path_to(@object), notice: 'There was an error casting your vote. Please try again.'
    end
  end

  def update
    if @vote.update_attributes(vote_params)
      redirect_back fallback_location: shallow_path_to(@vote.votable), notice: 'Vote successfully cast.'
    else
      redirect_back fallback_location: shallow_path_to(@vote.votable), notice: 'There was an error casting your vote. Please try again.'
    end
  end

  def destroy
    @vote.destroy
    redirect_back fallback_location: shallow_path_to(@vote.votable), notice: "Successfully unvoted."
  end


  private

    # Set the vote
    def set_vote
      @vote = Vote.find_by id: params[:id], voter: @current_user
    end

    # Set the object that we are voting on
    def set_votable_object
      raise ActionController::UnpermittedParameters.new([:vote][:votable_type]) unless Vote.votable_types.include?(params[:vote][:votable_type])
      object_class = params[:vote][:votable_type].constantize
      @object = object_class.find params[:vote][:votable_id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vote_params
      params.require(:vote).permit(:vote).merge(:voter => @current_user)
    end

end
