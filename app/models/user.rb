class User < ApplicationRecord
  has_secure_password
  has_secure_token :registration_token
  has_attached_file :profile_picture, styles: {
      large: ["250x250#", :jpg],
      medium: ["100x100#", :jpg]
    },
    :default_style => :medium,
    :url => "/system/:rails_env/users/:param/profile_picture/:style.:extension",
    :path => ":rails_root/public/system/:rails_env/users/:param/profile_picture/:style.:extension",
    :default_url => "/system/:rails_env/users/:param/profile_picture/:style.jpg"

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

  # Profile picture
  validates_with AttachmentSizeValidator, attributes: :profile_picture,
    less_than: 1.megabytes
  validates_with AttachmentContentTypeValidator, attributes: :profile_picture,
    content_type: ["image/jpeg", "image/gif", "image/png"]

  # Color Scheme
  validates :color_scheme,
    inclusion: {
      in: Color.color_options,
      message: "%{value} is not a valid option"
    }

  # before_validation :create_profile_if_not_exists, on: :create

  # create fallback profile_picture and symlinks after creation
  after_create :generate_fallback_profile_picture
  after_create :generate_symlink_for_fallback_profile_picture

  # re-generate fallback profile picture whenever name or color_scheme changes
  after_update :generate_fallback_profile_picture,
    if: "name_changed? or color_scheme_changed?"

  # create symlinks if profile_picture is removed
  after_update :generate_symlink_for_fallback_profile_picture,
    if: "profile_picture_updated_at_changed? and !profile_picture.present?"


  # We want to always use username in routes
  def to_param
    username
  end

  # returns both color_scheme and the font color for the color_scheme
  def color_scheme_with_font_color
    "#{color_scheme} #{Color.font_color_for(color_scheme)}"
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

  # generate fallback profile picture for user (using Avatarly)
  def generate_fallback_profile_picture

    # create profile picture
    fallback_profile_picture = Avatarly.generate_avatar(
      name,
      {
        :size =>  250,
        :background_color => Color.convert_to_hex(color_scheme),
        :font_color => Color.convert_to_hex(Color.font_color_for(color_scheme)),
        :format => 'jpg'
      }
    )

    # create directory if not exists
    FileUtils::mkdir_p "#{Rails.root}/public#{profile_picture.url}".rpartition('/').first

    # save file
    File.open("#{Rails.root}/public#{profile_picture.url}".rpartition('/').first + "/fallback.jpg", 'wb+') do |f|
      f.write fallback_profile_picture
    end

    if !profile_picture.present?
      touch :profile_picture_updated_at
    end
  end

  # create a symlink to the user's fallback profile picture
  def generate_symlink_for_fallback_profile_picture
    begin
      profile_picture.options[:styles].keys.each do |key|
        # create a symlink for each style of profile picture: medium, large, ...
        File.symlink(
          "#{Rails.root}/public#{profile_picture.url}".rpartition('/').first + "/fallback.jpg",
          "#{Rails.root}/public#{profile_picture.url}".rpartition('/').first + "/#{key.to_s}.jpg"
        )
      end
    rescue Errno::EEXIST => error
    end

    touch :profile_picture_updated_at
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
    # return the path for confirming the registration
    def registration_confirmation_path
      confirm_registration_path(
        :email => email,
        :registration_token => registration_token
      )
    end

    # sets profile_picture_updated_at to now
    def set_profile_picture_updated_at
      profile_picture_updated_at = Time.now
    end

  # protected
  # def create_profile_if_not_exists
  #   self.profile ||= Profile.new(:visibility => "is_network_only")
  # end
end
