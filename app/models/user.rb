class User < ApplicationRecord
  has_secure_password
  has_secure_token :registration_token

  include Rails.application.routes.url_helpers

  # # Associations
  # ## Profile
  has_one :profile, inverse_of: :user, dependent: :destroy

  # ## Posts
  has_many :posts, :foreign_key => "author_id", dependent: :destroy

  # ## Comments
  has_many :comments, :foreign_key => "author_id", dependent: :destroy

  # ## Likes
  has_many :likes, :foreign_key => "liker_id", dependent: :destroy
  # has_many :likes_on_posts --> where(:likable_type => "Post")
  # has_many :likes_on_comments --> where(:likable_type => "Comments")
  # has_many :liked_posts, :through => :likes, :source => :likable,  :source_type => 'Post'
  # has_many :liked_comments, :through => :likes, :source => :likable,  :source_type => 'Comment'

  # ## Private Conversations / Participantships in Private Conversations
  has_many :participantships_in_private_conversations,
    :class_name => "ParticipantshipInPrivateConversation",
    :foreign_key => "participant_id",
    :dependent => :destroy,
    :inverse_of => :participant
  has_many :private_conversations, :through => :participantships_in_private_conversations, :source => :private_conversation

  # ## Private Messages
  #has_many :private_messages, :through => :private_conversations, :source => :messages
  has_many :private_messages_sent, :class_name => "PrivateMessage",
    :foreign_key => "sender_id", :inverse_of => :sender, dependent: :destroy

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

  # name
  validates :name, presence: true

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

  # Email
  validates :email, presence: true
  validates :email, format: {
    with: /\A\S+@\S+\.\S+\z/,
    message: "seems invalid"
  }
  validates :email,
    uniqueness: { :case_sensitive => false }

  # Password
  validates :password, confirmation: true
  validates :password,
    length: { in: 8..50 }, unless: "password.nil?"


  # before_validation :create_profile_if_not_exists, on: :create

  # We want to always use username in routes
  def to_param
    username
  end

  # gets unread conversations
  def unread_private_conversations
    private_conversations.most_recent_activity_first.
      where('private_conversations.updated_at > participantship_in_private_conversations.read_at ' +
      'OR ' +
      'participantship_in_private_conversations.read_at IS NULL')
  end

  def friends
    friends_found + friends_made
  end

  # checks whether this user is friends with another user
  def has_friendship_with? user
    !! friends.include?(user)
  end

  # checks whether this user has received a friend request from another user
  def has_received_friend_request_from? user
    friendship_requests_received.exists?(sender_id: user.id)
  end

  # checks whether this user has sent a friend request to another user
  def has_sent_friend_request_to? user
    friendship_requests_sent.exists?(recipient_id: user.id)
  end

  # when printing the record to the screen
  def to_s
    username
  end

  # send the registration email
  def send_registration_email
    Mailjet::Send.create(
      "FromEmail": "hello@upshift.network",
      "FromName": "Upshift Network",
      "Subject": "Please Confirm Your Registration",
      "Mj-TemplateID": ENV['USER_REGISTRATION_EMAIL_TEMPLATE_ID'],
      "Mj-TemplateLanguage": "true",
      "Mj-trackclick": "1",
      recipients: [{
        'Email' => email,
        'Name' => name
        }],
      vars: {
        "NAME" => name,
        "CONFIRMATION_PATH" => registration_confirmation_path
      }
    )
  end

  # # Class Methods

  # converts the input to User
  def self.to_user input
    return nil unless input
    return input if input.is_a?(User)
    return User.find_by_username(input) if input.is_a?(String)
    raise ArgumentError.new("User.to_user only supports types User and String")
  end

  private
    # return the path for confirming the pending newsletter subscription
    def registration_confirmation_path
      confirm_registration_path(
        :email => email,
        :registration_token => registration_token
      )
    end

  # protected
  # def create_profile_if_not_exists
  #   self.profile ||= Profile.new(:visibility => "is_network_only")
  # end
end
