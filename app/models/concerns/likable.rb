module Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likable, dependent: :destroy
    has_many :likers, :through => :likes, :source => :liker
  end

  # whether the object can be liked by a given user
  def likable_by? user
    return false unless user
    ! self.liked_by?(user)
  end

  # whether the object can be unliked by a given user
  def unlikable_by? user
    return false unless user
    !! self.liked_by?(user)
  end

  # whether the object is liked by a given user
  def liked_by? user
    return self.likes.map{|like| like.liker_id}.include? user.id
  end

end
