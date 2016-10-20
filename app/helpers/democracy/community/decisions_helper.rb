module Democracy::Community::DecisionsHelper

  # Renders the appropriate vote action for a given vote_type (upvote,
  # downvote), decision, and current_vote status
  def vote_action vote_type, decision, current_vote
    if not current_vote
      # create a vote
      render partial: "votes/#{vote_type}/vote",
        locals: {vote: decision.votes.new}
    elsif current_vote.send("#{vote_type}?")
      # delete the vote
      render partial: "votes/#{vote_type}/unvote",
        locals: {vote: current_vote}
    else
      # change the vote
      render partial: "votes/#{vote_type}/revote",
        locals: {vote: current_vote}
    end
  end

end
