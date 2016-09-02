class User < ApplicationRecord
  has_secure_password

  # # Associations
  # ## Profile
  has_one :profile, inverse_of: :user, dependent: :destroy

  # ## Posts
  has_many :posts, :foreign_key => "author_id", dependent: :destroy

  # ## Comments
  has_many :comments, :foreign_key => "author_id", dependent: :destroy

  # ## Likes
  has_many :likes, :foreign_key => "liker_id", dependent: :destroy
  has_many :liked_posts, :through => :likes, :source => :likable,  :source_type => 'Post'
  has_many :liked_comments, :through => :likes, :source => :likable,  :source_type => 'Comment'

  # ## Private Conversations / Participantships in Private Conversations
  has_many :participantships_in_private_conversations,
    :class_name => "ParticipantshipInPrivateConversation",
    :foreign_key => "participant_id",
    :dependent => :destroy,
    :inverse_of => :participant
  has_many :private_conversations, :through => :participantships_in_private_conversations, :source => :private_conversation

  # ## Private Messages
  has_many :private_messages, :through => :private_conversations, :source => :messages
  has_many :private_messages_sent, :class_name => "PrivateMessage",
    :foreign_key => "sender_id", :inverse_of => :sender

  # ## Friendship Requests
  has_many :friendship_requests_sent,
    :class_name => "FriendshipRequest",
    :foreign_key => "sender_id",
    dependent: :destroy
  has_many :friendship_requests_received,
    :class_name => "FriendshipRequest",
    :foreign_key => "recipient_id",
    dependent: :destroy

  # ## Friendships / Friends
  has_many :friendships_initiated,
    :class_name => "Friendship",
    :foreign_key => "initiator_id",
    dependent: :destroy
  has_many :friends_found, :through => :friendships_initiated, :source => :acceptor
  has_many :friendships_accepted,
    :class_name => "Friendship",
    :foreign_key => "acceptor_id",
    dependent: :destroy
  has_many :friends_made, :through => :friendships_accepted, :source => :initiator

  # # Validations
  validates :profile, presence: true

  # Username
  validates :username,
    format: {
      with: /\A[a-zA-Z0-9_]+\z/,
      message: "must consist of upper- and lowercase letters, numbers and " +
        "underscores only"
    }
  validates :username,
    format: {
      with: /\A[a-zA-Z0-9]{1}/,
      message: "must start with a letter or number"
    }
  validates :username,
    format: {
      with: /[a-zA-Z0-9]{1}\z/,
      message: "must end with a letter or number"
    }
  validates :username,
    length: { in: 3..26 }
  validates :username,
    uniqueness: { :case_sensitive => false }


  before_validation :create_profile_if_not_exists, on: :create

  # We want to always use username in routes
  def to_param
    username
  end

  # get likes that have been made on posts
  def likes_on_posts
    return likes.where(:likable_type => "Post")
  end

  # get likes that have been made on comments
  def likes_on_comments
    return likes.where(:likable_type => "Comments")
  end

  # gets unread conversations
  def unread_private_conversations
    return private_conversations.most_recent_activity_first.
      where('private_conversations.updated_at > participantship_in_private_conversations.read_at ' +
      'OR ' +
      'participantship_in_private_conversations.read_at IS NULL')
  end

  def friends
    return friends_found + friends_made
  end

  # checks whether this user is friends with another user
  def is_friends_with user
    return friends.include?(user)
  end

  # checks whether this user has received a friend request from another user
  def has_received_friend_request_from user
    return friendship_requests_received.where(sender_id: user.id).any?
  end

  # checks whether this user has sent a friend request to another user
  def has_sent_friend_request_to user
    return friendship_requests_sent.where(recipient_id: user.id).any?
  end

  protected
   def create_profile_if_not_exists
     self.profile ||= Profile.new(:visibility => "is_network_only")
   end
end
