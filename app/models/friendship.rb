class Friendship < ApplicationRecord
  belongs_to :initiator, :class_name => "User"
  belongs_to :acceptor, :class_name => "User"

  # finds the record that contains the friendship between two users
  scope :find_friendships_between,
    ->(user_one, user_two) {
      where(:initiator => user_one).where(:acceptor => user_two).
        or(where(:initiator => user_two).where(:acceptor => user_one))
    }

  validates :initiator, presence: true
  validates :acceptor, presence: true

  validate :friendship_must_be_unique,
    if: "initiator.present? and acceptor.present?"

  after_create :destroy_friendship_requests

  private
    def friendship_must_be_unique
      if Friendship.find_friendships_between(initiator, acceptor).any?
        errors[:base] << "A friendship between #{initiator.name} and " +
                          "#{acceptor.name} already exists."
      end
    end

    # destroys the friendship requests that this friendship is based on
    def destroy_friendship_requests
      FriendshipRequest.
        find_friendship_requests_between(initiator, acceptor).
        destroy_all
    end
end
