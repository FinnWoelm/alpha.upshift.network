class Notification::Subscription < ApplicationRecord
  belongs_to :subscriber, class_name: "User", optional: false
  belongs_to :notification, optional: false

  # # Accessors
  enum reason_for_subscription: [ :author, :recipient, :commenter, :follower ], _prefix: "subscriber_is"
end
