module Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likable, dependent: :destroy
    has_many :likers, :through => :likes, :source => :liker
  end

  # whether the object can be liked by a given user
  def can_be_liked_by? user
    return false unless user
    return false if self.is_liked_by? user
    return true
  end

  # whether the object can be unliked by a given user
  def can_be_unliked_by? user
    return false unless user
    return true if self.is_liked_by? user
    return false
  end

  # whether the object is liked by a given user
  def is_liked_by? user
    # check if we have preloaded likes
    if self.association(:likes).loaded?
      return self.likes.map{|like| like.liker_id}.include? user.id
    else
      return self.likers.include? user
    end
  end

end
