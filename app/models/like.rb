class Like < ApplicationRecord

  def self.likable_types
    ["Post", "Comment"]
  end

  include Notifying

  # # Associations
  belongs_to :liker, :class_name => "User", optional: false
  belongs_to :likable, polymorphic: true, counter_cache: true, optional: false

  # # Validations
  validates :likable_type, inclusion: { in: likable_types,
    message: "%{value} is not a valid likable type" }

  validate :like_must_be_unique_for_user_and_content,
    if: Proc.new { |l| l.present? and l.likable_id.present? and l.likable_type.present? }

  private

    # validates that there is no existing like for this content by this user
    def like_must_be_unique_for_user_and_content
      if Like.exists?(
          likable_id: self.likable_id,
          likable_type: self.likable_type,
          liker: self.liker )
        errors[:base] << "You have already liked this #{self.likable_type.downcase}"
      end
    end

    # create notification
    def create_notification
      notification =
        Notification.
        create_with(:timestamps => self.created_at).
        find_or_initialize_by(
          :notifier => self.likable,
          :action_on_notifier => "like"
        )

      # create the notification action
      notification.actions.build(
        :actor => liker,
        :timestamps => created_at
      )

      # create the subscription(s)
      if notification.new_record?

        # subscribe post/comment author
        notification.subscriptions.build(
          :subscriber_id => self.likable.author_id,
          :reason_for_subscription => :author,
          :timestamps => self.created_at
        )

        # if a post is liked and the author and recipient are different,
        # then also subscribe the recipient
        if (likable_type.downcase == "post" and
            likable.author_id != likable.recipient_id)
          notification.subscriptions.build(
            :subscriber_id => self.likable.recipient_id,
            :reason_for_subscription => :recipient,
            :timestamps => created_at
          )
        end
      # else: if liker is subscribed, touch seen_at
      else
        Notification::Subscription.find_by(
          :notification => notification,
          :subscriber_id => liker_id
        ).
        try(:update, {:seen_at => created_at})
      end

      notification.save
    end


    # destroy notification
    def destroy_notification

      likable_notification =
        Notification.
        find_by(
          :notifier => self.likable,
          :action_on_notifier => "like"
        )

      # reinitialize the notification if other likes exist and this like is
      # among the last four actions
      if (self.likable.likes_count > 0 and
        (likable_notification.others_acted_before.nil? or
        self.created_at >= likable_notification.others_acted_before))
        likable_notification.reinitialize_actions
      else
        # destroy the notification
        likable_notification.destroy
      end
    end

end
