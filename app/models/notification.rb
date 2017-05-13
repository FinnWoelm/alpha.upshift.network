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

  # # Scopes
  # returns notifications for the given user
  scope :for_user, -> (user) {
    includes(actions: [:actor]).
    includes(:subscriptions).
    preload(:notifier).
    where(notification_subscriptions: {subscriber_id: user.id}).
    where('"notification_actions"."created_at" >= notification_subscriptions.created_at and notification_actions.actor_id != ?', user.id).
    order("notification_actions.created_at DESC")

    # Alternative Syntax
    # unfortunately this does not work with includes().
    # Manually preloading is complex because of the conditions on the preloaded
    # associations (action created after user has subscribed and actor is not
    # user).
    # joins(:subscriptions, :actions).
    # where(notification_subscriptions: {subscriber_id: user.id}).
    # where('"notification_actions"."created_at" >= notification_subscriptions.created_at and notification_actions.actor_id != ?', user.id).
    # group("notifications.id").
    # order("max(notification_actions.created_at) DESC")
  }

  scope :unseen_only, -> {
    joins('INNER JOIN "notification_actions" AS "acts" ON "acts"."notification_id" = "notifications"."id" AND "acts"."created_at" > COALESCE(notification_subscriptions.seen_at, to_timestamp(\'0001-01-01 23:59:59\', \'YYYY-MM-DD HH24:MI:SS\'))')
  }

  # # Pagination
  self.per_page = 15

  # # Accessors
  enum action_on_notifier: [ :post, :comment, :like ], _suffix: true

  # # Validations
  validates :notifier_type, inclusion: { in: notifier_types,
    message: "%{value} is not a valid notifier type" }

  # reinitialize the notification actions
  def reinitialize_actions

    # clear existing actions
    actions.clear

    case action_on_notifier.to_s
    when "comment"
      sort_by = :created_at
      actor_column = "author"
    when "like"
      sort_by = :id
      actor_column = "liker"
    end

    # subquery: get distinct actions
    query_for_distinct_actions =
      notifier.comments.unscoped.select("distinct on (#{actor_column}_id) *").order("#{actor_column}_id, #{sort_by} DESC")
    # main query: sort actions to get most recent action first
    query_for_last_actions =
      notifier.comments.unscoped.select("*").limit(4).order("#{sort_by} DESC")

    # combine queries to get last actions from a table of distinct actions
    last_distinct_actions =
      notifier.comments.find_by_sql(
        query_for_last_actions.
        to_sql.
        gsub(
          /FROM \".*?\"/,
          "FROM (#{query_for_distinct_actions.to_sql}) distinct_actions"
        )
    )

    # reinitalize_actions
    last_distinct_actions[0..2].reverse.each do |action|
      Notification::Action.create(
        :notification => self,
        :actor_id => action.send(:"#{actor_column}_id"),
        :timestamps => action.created_at
      )
    end

    # set others acted before to timestamp of action 4 or nil
    self.update(
      :others_acted_before => last_distinct_actions[3].try(:created_at)
    )
  end
end