class Comment < ApplicationRecord

  def self.commentable_types
    ["Post", "Democracy::Community::Decision"]
  end

  include Likable
  include Notifying

  belongs_to :author, :class_name => "User", optional: false
  belongs_to :commentable, polymorphic: true, optional: false

  default_scope -> { order('comments.created_at ASC') }

  validates :commentable_type, inclusion: { in: commentable_types,
    message: "%{value} is not a valid commentable type" }
  validates :content, presence: true
  validates :content, length: { maximum: 1000 }

  # Validation: User can only write comments on posts that they can see
  validate :author_must_be_able_to_see_commentable, on: :create,
    if: "author.present? and commentable.present?"

  # whether the comment can be deleted by a given user
  def deletable_by? user
      return false unless user
      return self.author.id == user.id
  end

  private

    # Validation: User can only write comments on posts that they can see
    def author_must_be_able_to_see_commentable
      if not commentable.readable_by? author
        errors[:base] << "An error occurred. " +
          "Either the #{self.commentable_type.downcase} never existed, " +
          "it does not exist anymore, " +
          "or you do not have permission to view it."
      end
    end

    # create notification
    def create_notification
      notification =
        Notification.
        find_by(
          :notifier => self.commentable,
          :action_on_notifier => "comment"
        )

      # subscribe comment author to notifications
      subscription =
        Notification::Subscription.
        create_with(
          :reason_for_subscription => :commenter,
          :timestamps => created_at
        ).
        find_or_initialize_by(
          :notification => notification,
          :subscriber => author
        )

      if subscription.new_record?
        # if author is not yes a subscriber, add subscriber to notification
        notification.subscriptions << subscription
      else
        # if author is already a subscriber, just touch :seen_at
        subscription.update(seen_at: created_at)
      end

      # create the notification action
      notification.actions.create(
        :actor => author,
        :timestamps => created_at
      )
    end

    # destroy notification
    def destroy_notification
      # destroy all notifications related to comment
      Notification.where(:notifier => self).destroy_all

      commentable_notification =
        Notification.
        find_by(
          :notifier => self.commentable,
          :action_on_notifier => "comment"
        )

      # if author does not have another comment and isn't commentable author or
      # recipient, then remove the author's subscription
      author_has_another_comment =
        Comment.exists?(:commentable => commentable, :author_id => self.author_id)
      author_is_commentable_owner_or_recipient =
        (author_id == commentable.author_id) or (author_id == commentable.recipient_id)
      unless author_has_another_comment or author_is_commentable_owner_or_recipient
        Notification::Subscription.where(
          :notification => commentable_notification,
          :subscriber_id => author_id,
          :reason_for_subscription => :commenter
        ).destroy_all
      end

      # reinitialize the notification if the comment is among the last four
      # actions
      if (commentable_notification.others_acted_before.nil? or
          self.created_at >= commentable_notification.others_acted_before)
        commentable_notification.reinitialize_actions
      end
    end

end
