class Post < ApplicationRecord

  include Likable
  include Commentable
  include Notifying

  # the user who wrote the post
  belongs_to :author, :class_name => "User", optional: false
  # the user to which the post has been made
  belongs_to :recipient, :class_name => "User", optional: false

  # # Scopes
  # returns posts made by friends/user and sent to friends/user
  scope :from_and_to_network_of_user, -> (user) {
    where(
      "posts.author_id = :user_id or " +
      "posts.recipient_id = :user_id or " +
      "(posts.author_id IN (:friends_ids) AND " +
      "posts.recipient_id IN (:friends_ids))",
      {
        :user_id => user.id,
        :friends_ids => user.friends_ids
      }
    )
  }

  # returns posts ordered by date of creation (most recent first)
  scope :most_recent_first, -> {
    order('posts.created_at DESC')
  }

  # return posts made and received by a given user
  scope :made_and_received_by_user, -> (user) {
    where(author: user).or(Post.where(recipient: user))
  }

  # returns posts where author and recipient are visible to the user
  scope :readable_by_user, -> (user) {
    joins("INNER JOIN users AS authors ON authors.id = posts.author_id").
    joins("INNER JOIN users AS recipients ON recipients.id = posts.recipient_id").
    where("authors.id = :user_id OR recipients.id = :user_id", {
      :user_id => user ? user.id : -1
      }).
    or(
      Post.
      joins("INNER JOIN users AS authors ON authors.id = posts.author_id").
      joins("INNER JOIN users AS recipients ON recipients.id = posts.recipient_id").
      merge( User.viewable_by_user(user, "authors")).
      merge( User.viewable_by_user(user, "recipients"))
    )
  }

  # returns posts with default associations needed for showing post
  scope :with_associations, -> {
    includes(:comments).includes(:author).includes(:likes).
    includes(:recipient)
  }

  # # Pagination
  self.per_page = 10

  # # Accessors
  attr_accessor :recipient_username

  # # Validations
  validates :content, presence: true
  validates :content, length: { maximum: 5000 }
  validate :author_can_post_to_recipient, on: :create,
    if: "author.present? and recipient.present?"

  def readable_by? user
    if user
      return true if (user.id == self.author_id or user.id == self.recipient_id)
    end
    !! (self.author.viewable_by?(user) and self.recipient.viewable_by?(user))
  end

  # whether the post can be deleted by a given user
  def deletable_by? user
    return false unless user
    return (self.author.id == user.id || self.recipient.id == user.id)
  end

  def recipient_username=(username)
    @recipient_username = username
    self.recipient = User.to_user(@recipient_username)
  end

  def recipient_username
    return recipient.username if recipient
    @recipient_username
  end

  private

    # validate that author can post to the profile
    def author_can_post_to_recipient
      if not recipient.viewable_by? author
        errors.add :recipient, "does not exist or is private"
      end
    end

    # create notification
    def create_notification

      # create notification for comments on post
      comment_notification = Notification.create(
        :notifier => self,
        :action_on_notifier => :comment,
        :timestamps => created_at
      )
      # subscribe author to comments on the post
      comment_notification.subscriptions.create(
        :subscriber_id => author_id,
        :reason_for_subscription => :author,
        :timestamps => created_at
      )

      if author_id != recipient_id

        # subscribe recipient to comments on the post
        comment_notification.subscriptions.create(
          :subscriber_id => recipient_id,
          :reason_for_subscription => :recipient,
          :timestamps => created_at
        )

        # create notification for post
        post_notification = Notification.create(
          :notifier => self,
          :action_on_notifier => :post,
          :timestamps => created_at
        )

        # subscribe recipient to post notification
        post_notification.subscriptions.create(
          :subscriber_id => recipient_id,
          :reason_for_subscription => :recipient,
          :timestamps => created_at
        )

        # create the post action (must be last!)
        post_notification.actions.create(
          :actor_id => author_id,
          :timestamps => created_at
        )
      end
    end

    def destroy_notification
      Notification.where(:notifier => self).destroy_all
    end

end
