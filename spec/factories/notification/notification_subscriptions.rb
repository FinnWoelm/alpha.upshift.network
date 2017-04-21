FactoryGirl.define do
  factory :notification_subscription, class: Notification::Subscription do
    association :subscriber, factory: :user
    notification
    reason_for_subscription { Notification::Subscription.reason_for_subscriptions.keys.sample }
    seen_at { Time.now }
  end
end
