class Friendship < ApplicationRecord
  belongs_to :initiator, :class_name => "User"
  belongs_to :acceptor, :class_name => "User"

  # finds the record that contains the friendship between two users
  scope :find_friendships_between, -> (user_one, user_two) {
    where(:initiator => user_one).where(:acceptor => user_two).
    or(Friendship.where(:initiator => user_two).where(:acceptor => user_one))
  }

  validates :initiator, presence: true
  validates :acceptor, presence: true

  validate :friendship_must_be_unique,
    if: Proc.new { |f| f.initiator.present? and f.acceptor.present? }

  after_create :destroy_friendship_requests

  def self.friends_ids_for user
    self.select(
      "CASE friendships.acceptor_id
        WHEN #{sanitize_sql(user.id)} THEN friendships.initiator_id
        ELSE friendships.acceptor_id
      END AS ID"
    ).
    where("acceptor_id = :user_id or initiator_id = :user_id",
      {
        :user_id => user.id
      }).
    map(&:id)
  end

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
