module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
    has_many :voters, :through => :votes, :source => :voter

    serialize :votes_count
  end

  # whether the object can be voted by a given user
  def votable_by? user
    return false unless user
    ! self.voted_by?(user)
  end

  # whether the object can be unvoted by a given user
  def unvotable_by? user
    return false unless user
    !! self.voted_by?(user)
  end

  # whether the object is voted by a given user
  def voted_by? user
    return self.votes.map{|vote| vote.voter_id}.include? user.id
  end

  # Custom Counter Cache using serialize
  # increase count of votes for a specific type
  def increase_votes_count vote
    self.votes_count[:total] += 1
    self.votes_count[vote.pluralize.to_sym] += 1
    self.update_column(:votes_count, votes_count)
  end

  # decrease count of votes for a specific type
  def decrease_votes_count vote
    self.votes_count[:total] -= 1
    self.votes_count[vote.pluralize.to_sym] -= 1
    self.update_column(:votes_count, votes_count)
  end

  # decrease count of votes for one type and increase for another
  def modify_votes_count new_vote, previous_vote
    self.votes_count[new_vote.pluralize.to_sym] += 1
    self.votes_count[previous_vote.pluralize.to_sym] -= 1
    self.update_column(:votes_count, votes_count)
  end

end
