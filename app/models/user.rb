class User < ApplicationRecord
  has_secure_password
  has_secure_token :registration_token
  has_attached_file :profile_picture, styles: {
      large: ["250x250#", :jpg],
      medium: ["100x100#", :jpg]
    },
    :default_style => :medium,
    :url =>
      Rails.configuration.attachment_storage_location +
      "users/:param/profile_picture/:style.:extension",
    :path =>
      ":rails_root" +
      Rails.configuration.attachment_storage_location +
      "users/:param/profile_picture/:style.:extension",
    :default_url =>
      Rails.configuration.attachment_storage_location +
      "users/:param/profile_picture/:style.jpg"

  include Rails.application.routes.url_helpers

  # # Attributes
  # ## Username should never be changed
  attr_readonly :username

  # # Associations
  # ## Profile
  has_one :profile, inverse_of: :user, dependent: :destroy

  # ## Posts
  has_many :posts_made, :class_name => "Post", :foreign_key => "author_id",
    dependent: :destroy
  has_many :posts_received, :through => :profile, :source => :posts

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

  # # Accessors
  enum visibility: [ :private, :network, :public ], _suffix: true
  attr_accessor(:friends_ids)
  serialize :options, Hash

  # alias the Paperclip setter, so that we can extend it with custom calls
  alias_method 'profile_picture_via_paperclip=', 'profile_picture='


  # # Scopes

  # returns only users visible to 'user'
  scope :viewable_by_user, -> (user, join_table_users_name = "users") do
    where(
      "\"#{join_table_users_name}\".visibility = :public or " +
      "\"#{join_table_users_name}\".visibility = :network or " +
      "(\"#{join_table_users_name}\".visibility = :private and " +
      "\"#{join_table_users_name}\".id IN (:friend_ids))",
    {
      :join_table_users_name  => join_table_users_name,
      :public => User.visibilities["public"],
      :network => user ? User.visibilities["network"] : -1,
      :private => user ? User.visibilities["private"] : -1,
      :friend_ids => user ? user.friends_ids + [user.id] : []
    })
  end

  # returns users along with ids of their friends (made & found)
  scope :with_friends_ids, -> do
    joins(
      "LEFT OUTER JOIN friendships ON friendships.acceptor_id = users.id OR " +
      "friendships.initiator_id = users.id").
    merge(
      User.select(
        "users.*, array_agg(
          CASE friendships.acceptor_id
            WHEN users.id THEN friendships.initiator_id
            ELSE friendships.acceptor_id
          END) friends_ids")).
    group("users.id")
  end

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
  # Username cannot be blacklisted (be a previously-used username)
  validate :username_cannot_be_blacklisted, on: :create
  # Username cannot be any existing Upshift route
  validates :username,
    exclusion: {
      in: Helper::RouteRecognizer.get_initial_path_segments,
      message: "%(value) is not available"
    },
    on: :create
  # Username cannot be any dictionary word
  validate :username_cannot_be_a_dictionary_word, on: :create

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
  validates_with AttachmentPresenceValidator, attributes: :profile_picture
  validates_with AttachmentSizeValidator, attributes: :profile_picture,
    less_than: 5.megabytes
  validates_with AttachmentContentTypeValidator, attributes: :profile_picture,
    content_type: ["image/jpeg", "image/gif", "image/png"]

  # Color Scheme
  validates :color_scheme,
    inclusion: {
      in: Color.color_options,
      message: "%{value} is not a valid option"
    }

  # # Callbacks
  #
  # ## After initialize:
  # ### set_default_options
  #
  # ## After find:
  # ### set friends_ids
  #
  # ## Before save:
  # ### auto_generate_profile_picture (if name or color was changed and
  # ###                               auto-generation is on)
  #
  # ## After save:
  # ### destroy_original_profile_picture (if profile picture was added)
  #
  # ## After destroy:
  # ### blacklist_username
  # ### delete_attachment_folder

  # blacklist username (to prevent re-assignment)
  after_destroy :blacklist_username

  # delete folder containing attachments of this user
  after_destroy :delete_attachment_folder

  # set friends_ids after finding records in database
  after_find { |user| user.friends_ids = user["friends_ids"] }

  # set default options for user
  after_initialize :set_default_options

  # destroy the original profile picture (b/c it is not needed)
  after_save :destroy_original_profile_picture,
    if: "profile_picture_updated_at_changed?"

  # auto generate profile picture when name or color_scheme changes
  before_save :auto_generate_profile_picture,
    if: "(options[:auto_generate_profile_picture] and (name_changed? or color_scheme_changed?))"

  # generate fallback profile picture for user (using Avatarly)
  def auto_generate_profile_picture
    # create profile picture
    self.profile_picture =
      "data:image/jpeg;base64," + Base64.encode64(
      Avatarly.generate_avatar(
        name,
        {
          :size =>  250,
          :background_color => Color.convert_to_hex(color_scheme),
          :font_color => Color.convert_to_hex(Color.font_color_for(color_scheme)),
          :format => 'jpg'
        }
      )
    )

    # set auto-generation to true
    options[:auto_generate_profile_picture] = true
  end

  # returns both color_scheme and the font color for the color_scheme
  def color_scheme_with_font_color
    "#{color_scheme} #{Color.font_color_for(color_scheme)}"
  end

  def friends
    friends_found + friends_made
  end

  def friends_ids
    @friend_ids ||= Friendship.friends_ids_for(self)
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

  # returns post made and received by this user
  def posts_made_and_received
    Post.made_and_received_by_user(self)
  end

  # set the profile picture (delegate to Paperclip + custom calls)
  def profile_picture=(picture)

    # delegate to the Paperclip setter; abort if error is encountered
    begin
      self.profile_picture_via_paperclip = picture
    rescue => e
      return logger.error e.message
    end

    # set auto-generation to false
    options[:auto_generate_profile_picture] = false

    # generate the fallback profile picture
    auto_generate_profile_picture if picture.nil?
  end

  # We want to always use username in routes
  def to_param
    username
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

  # gets unread conversations
  def unread_private_conversations
    private_conversations.most_recent_activity_first.
      where('private_conversations.updated_at > participantship_in_private_conversations.read_at ' +
      'OR ' +
      'participantship_in_private_conversations.read_at IS NULL')
  end

  # whether the user is visible to a given viewer
  def viewable_by? viewer

    # public profile can be seen by everyone
    return true if self.public_visibility?

    # public viewers cannot see beyond this!
    return false if viewer.nil?

    # network user: own profile
    return true if viewer.id == self.id

    # network user: network profile
    return true if self.network_visibility?

    # network user: friend's profile
    return true if self.private_visibility? and viewer.has_friendship_with?(self)

    # other cases: false
    return false
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

    # blacklists the user's username (to prevent future re-assignment)
    def blacklist_username
      Helper::BlacklistedUsername.create(:username => self.username)
    end

    # deletes the folder of attachments belonging to this user
    def delete_attachment_folder
      path_to_attachment =
        Paperclip::Interpolations.interpolate(
          self.profile_picture.options[:path],
          self.profile_picture,
          "medium"
        )
      path_to_folder =
        File.expand_path("..", File.dirname(path_to_attachment))
      FileUtils.remove_dir(path_to_folder)
    end

    # destroy the original profile picture (b/c it is not needed)
    def destroy_original_profile_picture
      File.unlink(self.profile_picture.path(:original))
    end

    # return the path for confirming the registration
    def registration_confirmation_path
      confirm_registration_path(
        :email => email,
        :registration_token => registration_token
      )
    end

    # set the default user options
    def set_default_options
      self.options.reverse_update({
        :auto_generate_profile_picture => true
      })
    end

    def username_cannot_be_a_dictionary_word
      if Helper::Dictionary.exists? self.username
        errors.add(:username, "is not available")
      end
    end

    def username_cannot_be_blacklisted
      if Helper::BlacklistedUsername.exists? username: self.username
        errors.add(:username, "is not available")
      end
    end
end
