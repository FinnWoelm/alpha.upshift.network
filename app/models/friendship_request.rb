class FriendshipRequest < ApplicationRecord
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"

  # finds the record that contains the friendship request between two users
  scope :find_friendship_request_between,
    ->(user_one, user_two) {
      where(:sender => user_one).where(:recipient => user_two).
        or(FriendshipRequest.where(:sender => user_two).where(:recipient => user_one)).
        first
    }

  validates :sender, presence: true
  validates :recipient, presence: true

  validate :recipient_profile_must_be_visible_to_sender,
    :friendship_request_is_unique,
    :friendship_must_not_already_exist,
    if: "sender.present? and recipient.present?"

  def recipient_profile_must_be_visible_to_sender
    if not recipient.profile.can_be_seen_by?(sender)
      errors[:base] << "User does not exist or profile is private"
    end
  end

  def friendship_request_is_unique
    if FriendshipRequest.where(sender: sender).where(recipient: recipient).any?
      errors[:base] << "You have already sent a friend request to this user"
    end
    if FriendshipRequest.where(sender: recipient).where(recipient: sender).any?
      errors[:base] << "#{recipient.name} has already sent a friend request to you"
    end
  end

  def friendship_must_not_already_exist
    if sender.has_friendship_with?(recipient)
      errors[:base] << "You are already friends with #{recipient.name}"
    end
  end

end
