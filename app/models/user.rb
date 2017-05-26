class User < ApplicationRecord
  has_attached_file :profile_picture, styles: {
      large: ["250x250#", :jpg],
      medium: ["100x100#", :jpg]
    },
    :default_style => :medium,
    :url => "/:param/profile_picture/:style.:extension",
    :path =>
      ":rails_root" +
      Rails.configuration.attachment_storage_location +
      "users/:param/profile_picture/:style.:extension",
    :default_url => "/missing_attachment/profile_picture.jpg"
    has_attached_file :profile_banner, styles: {
        original: ["1600x500#", :jpg]
      },
      :default_style => :original,
      :url => "/:param/profile_banner/:style.:extension",
      :path =>
        ":rails_root" +
        Rails.configuration.attachment_storage_location +
        "users/:param/profile_banner/banner.:extension",
      :default_url => "/missing_attachment/profile_banner.jpg"

  include Rails.application.routes.url_helpers

  # # Attributes
  # ## Username should never be changed
  attr_readonly :username

  # # Associations

  # ## Acount
  belongs_to :account, optional: false, inverse_of: :user

  # ## Posts
  has_many :posts_made, :class_name => "Post", :foreign_key => "author_id",
    dependent: :destroy
  has_many :posts_received, :class_name => "Post", :foreign_key => "recipient_id",
    dependent: :destroy

  # ## Comments
  has_many :comments, -> { includes :commentable }, :foreign_key => "author_id", dependent: :destroy

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
    :foreign_key => "sender_id", :inverse_of => :sender, dependent: :delete_all

  # ## Friendship Requests
  has_many :friendship_requests_sent,
    -> { includes :recipient },
    :class_name => "FriendshipRequest",
    :foreign_key => "sender_id",
    dependent: :destroy
  has_many :friendship_requests_received,
    :class_name => "FriendshipRequest",
    :foreign_key => "recipient_id",
    dependent: :delete_all

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

  # ## Notifications
  has_many :notification_actions, class_name: "Notification::Action",
    dependent: :delete_all, foreign_key: "actor_id"
  has_many :notifications_created, class_name: "Notification",
    through: :notification_actions, source: :notification
  has_many :notification_subscriptions, class_name: "Notification::Subscription",
    dependent: :delete_all, foreign_key: "subscriber_id"

  # # Accessors
  enum visibility: [ :private, :network, :public ], _suffix: true
  attr_accessor(:friends_ids)
  attr_reader :delete_profile_picture, :delete_profile_banner
  attr_reader :unread_conversations_count, :unread_notifications_count
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

  # Profile picture
  validates_with AttachmentSizeValidator, attributes: :profile_picture,
    less_than: 10.megabytes
  validates_with AttachmentContentTypeValidator, attributes: :profile_picture,
    content_type: ["image/jpeg", "image/gif", "image/png"]

  # Profile banner
  validates_with AttachmentSizeValidator, attributes: :profile_banner,
    less_than: 10.megabytes
  validates_with AttachmentContentTypeValidator, attributes: :profile_banner,
    content_type: ["image/jpeg", "image/gif", "image/png"]


  # Color Scheme
  validates :color_scheme,
    inclusion: {
      in: Color.color_options,
      message: "%{value} is not a valid option"
    }

  # # Callbacks
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
  # ### destroy_notifications

  # blacklist username (to prevent re-assignment)
  after_destroy :blacklist_username

  # delete folder containing attachments of this user
  after_destroy :delete_attachment_folder

  # destroy notifications
  after_destroy :destroy_notifications

  # set friends_ids after finding records in database
  after_find { |user| user.friends_ids = user["friends_ids"] }

  # destroy the original profile picture (b/c it is not needed)
  after_save :destroy_original_profile_picture,
    if: Proc.new { |u| u.saved_change_to_profile_picture_updated_at? and u.profile_picture.present? }

  # auto generate profile picture when name or color_scheme changes
  before_save :auto_generate_profile_picture,
    if: Proc.new { |u| u.options[:auto_generate_profile_picture] and (u.name_changed? or u.color_scheme_changed?) }

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

  # returns the color scheme's base color
  def color_scheme_base
    "#{color_scheme.split(' ').first}"
  end

  # sets the color scheme's base color
  def color_scheme_base=(base)
    self.color_scheme = [base, color_scheme.split(' ').second].join(" ")
  end

  # returns the color scheme's shade
  def color_scheme_shade
    "#{color_scheme.split(' ').second}"
  end

  # sets the color scheme's shade
  def color_scheme_shade=(shade)
    self.color_scheme = [color_scheme.split(' ').first, shade].join(" ")
  end

  # returns both color_scheme and the font color for the color_scheme
  def color_scheme_with_font_color
    "#{color_scheme} #{Color.font_color_for(color_scheme)}"
  end

  # delete the profile banner
  def delete_profile_banner=(delete_picture)
    self.profile_banner = nil if delete_picture == "true" and profile_banner.present?
  end

  # delete the profile picture
  def delete_profile_picture=(delete_picture)
    self.profile_picture = nil if delete_picture == "true" and profile_picture.present?
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

  # returns the user's notifications
  def notifications
    Notification.for_user(self)
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

  # returns base 64 representation of the user's profile picture
  def profile_picture_base64 size = nil
    size ||= self.profile_picture.options[:default_style]
    "data:image/jpeg;base64," + Base64.encode64(File.read(self.profile_picture.path(size)))
  end

  # We want to always use username in routes
  def to_param
    username
  end

  # when printing the record to the screen
  def to_s
    username
  end

  # gets unread conversations
  def unread_private_conversations
    private_conversations.most_recent_activity_first.
      where('private_conversations.updated_at > participantship_in_private_conversations.read_at ' +
      'OR ' +
      'participantship_in_private_conversations.read_at IS NULL')
  end

  # gets the number of unread conversations, max 20
  def unread_conversations_count
    @unread_conversations_count ||=
      unread_private_conversations.count
  end

  # gets the number of unread notifications, max 20
  def unread_notifications_count
    @unread_notifications_count ||=
      Notification.for_user(self).unseen_only.distinct_count
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
      FileUtils.remove_dir(path_to_folder) if Dir.exists?(path_to_folder)
    end

    # destroy all notifications where the user is notifier
    def destroy_notifications
      Notification.where(:notifier => self).destroy_all
    end

    # destroy the original profile picture (b/c it is not needed)
    def destroy_original_profile_picture
      File.unlink(self.profile_picture.path(:original))
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
