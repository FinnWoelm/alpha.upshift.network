class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile
  enum visibility: [ :is_private, :is_network_only, :is_public ]

  validates :user, presence: true

  def can_be_seen_by? user

    # public profile can be seen by everyone
    return true if self.is_public?

    # public users cannot see beyond this!
    return false if user.nil?

    # network user: own profile
    return true if user.id == self.user.id

    # network user: network profile
    return true if self.is_network_only?

    # network user: friend's profile
    return true if self.is_private? and user.has_friendship_with?(self.user)

    # other cases: false
    return false
  end
end
