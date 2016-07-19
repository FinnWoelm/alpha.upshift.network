class Profile < ApplicationRecord
  belongs_to :user
  enum visibility: [ :is_private, :is_network_only, :is_public ]

  validates :user, presence: true

  def can_be_seen_by user
    # public user
    if user.nil?
      return self.is_public?
    end

    # network user: own profile
    return true if user.id == self.user.id

    # network user: network profile
    return true if self.is_network_only?

    # network user: friend's profile
    # return true if self.is_private? and user.is_friend_of(self.user)

    # other cases: false
    return false
  end
end
