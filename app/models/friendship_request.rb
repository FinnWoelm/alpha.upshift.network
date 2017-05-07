class FriendshipRequest < ApplicationRecord
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"

  # finds the record that contains the friendship request between two users
  scope :find_friendship_requests_between,
    ->(user_one, user_two) {
      where(:sender => user_one).where(:recipient => user_two).
        or(where(:sender => user_two).where(:recipient => user_one))
    }

  validates :sender, presence: true
  validates :recipient, presence: true

  validate :recipient_profile_must_be_viewable_by_sender,
    :friendship_request_is_unique,
    :friendship_must_not_already_exist,
    if: Proc.new { |f| f.sender.present? and f.recipient.present? }

  private
    def recipient_profile_must_be_viewable_by_sender
      unless recipient.viewable_by?(sender)
        errors[:base] << "User does not exist or profile is private"
      end
    end

    def friendship_request_is_unique
      if FriendshipRequest.find_friendship_requests_between(sender, recipient).any?
        errors[:base] << "A friendship request between #{sender.name} and " +
                          "#{recipient.name} already exists."
      end
    end

    def friendship_must_not_already_exist
      if sender.has_friendship_with?(recipient)
        errors[:base] << "You are already friends with #{recipient.name}"
      end
    end

end
