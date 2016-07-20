class Friendship < ApplicationRecord
  belongs_to :initiator, :class_name => "User"
  belongs_to :acceptor, :class_name => "User"

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
