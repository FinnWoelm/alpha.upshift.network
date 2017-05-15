class FriendshipRequest < ApplicationRecord

  include Notifying

  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"

  # finds the record that contains the friendship request between two users
  scope :find_friendship_requests_between,
    ->(user_one, user_two) {
      where(:sender => user_one).where(:recipient => user_two).
        or(where(:sender => user_two).where(:recipient => user_one))
    }

  validates :sender, presence: true
  validates :recipient, presence: true

  validate :recipient_profile_must_be_viewable_by_sender,
    :friendship_request_is_unique,
    :friendship_must_not_already_exist,
    if: Proc.new { |f| f.sender.present? and f.recipient.present? }

  private
    def create_notification
      notification =
        Notification.
        create_with(:timestamps => self.created_at).
        find_or_initialize_by(
          :notifier => self.recipient,
          :action_on_notifier => "friendship_request"
        )

      # create the notification action
      notification.actions.build(
        :actor => self.sender,
        :timestamps => created_at
      )

      # create the subscription(s)
      if notification.new_record?

        # subscribe recipient of friendship request
        notification.subscriptions.build(
          :subscriber => self.recipient,
          :reason_for_subscription => :recipient,
          :timestamps => self.created_at
        )
      end

      notification.save
    end

    def destroy_notification

      notification =
        Notification.
        find_by(
          :notifier => self.recipient,
          :action_on_notifier => "friendship_request"
        )

      # destroy the notification if no other friendship requests exist
      if not FriendshipRequest.exists?(:recipient => self.recipient)
        notification.destroy
      # reinitialize the notification if this request is among the last four actions
      elsif notification.others_acted_before.nil? or self.created_at >= notification.others_acted_before
        notification.reinitialize_actions
      end
    end

    def recipient_profile_must_be_viewable_by_sender
      unless recipient.viewable_by?(sender)
        errors[:base] << "User does not exist or profile is private"
      end
    end

    def friendship_request_is_unique
      if FriendshipRequest.find_friendship_requests_between(sender, recipient).any?
        errors[:base] << "A friendship request between #{sender.name} and " +
                          "#{recipient.name} already exists."
      end
    end

    def friendship_must_not_already_exist
      if sender.has_friendship_with?(recipient)
        errors[:base] << "You are already friends with #{recipient.name}"
      end
    end

end
