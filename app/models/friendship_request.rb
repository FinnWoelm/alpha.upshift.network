class FriendshipRequest < ApplicationRecord
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"

  validates :sender, presence: true
  validates :recipient, presence: true

  validate :recipient_profile_must_be_visible_to_sender,
    if: "sender.present? and recipient.present?"

  def recipient_profile_must_be_visible_to_sender
    if not recipient.profile.can_be_seen_by(sender)
      errors[:base] << "User does not exist or profile is private"
    end
  end
end
