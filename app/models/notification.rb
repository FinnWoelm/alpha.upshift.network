class Notification < ApplicationRecord

  def self.notifier_types
    ["Post", "Comment"]
  end

  # # Associations
  belongs_to :notifier, polymorphic: true, optional: false
  has_many :actions, class_name: "Notification::Action",
    dependent: :delete_all
  has_many :actors, through: :actions, source: :actor
  has_many :subscriptions, class_name: "Notification::Subscription",
    dependent: :delete_all
  has_many :subscribers, through: :subscriptions, source: :subscriber

  # # Accessors
  enum action_on_notifier: [ :post, :comment, :like ], _suffix: true

  # # Validations
  validates :notifier_type, inclusion: { in: notifier_types,
    message: "%{value} is not a valid notifier type" }
end
