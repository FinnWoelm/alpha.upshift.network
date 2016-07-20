class Friendship < ApplicationRecord
  belongs_to :initiator, :class_name => "User"
  belongs_to :acceptor, :class_name => "User"

  # finds the record that contains the friendship between two users
  scope :find_friendship_between,
    ->(user_one, user_two) {
      where(:initiator => user_one).where(:acceptor => user_two).
        or(Friendship.where(:initiator => user_two).where(:acceptor => user_one)).
        first
    }

  validates :initiator, presence: true
  validates :acceptor, presence: true

  after_create :destroy_friendship_request

  protected
    # destroys the friendship request that this friendship is based on
    def destroy_friendship_request
      friendship_request = FriendshipRequest.where(:sender => initiator).where(:recipient => acceptor)

      if friendship_request.any?
        friendship_request.each { |request| request.destroy }
      end
    end
end
