FactoryGirl.define do
  factory :notification_action, class: Notification::Action do
    association :actor, factory: :user
    notification
  end
end
