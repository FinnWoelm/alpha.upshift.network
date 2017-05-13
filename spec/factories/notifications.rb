FactoryGirl.define do
  factory :notification do
    association :notifier, factory: :post_to_self
    others_acted_before { Time.zone.now - 3.days }
    action_on_notifier :post

    factory :post_notification do
    end

    factory :comment_notification do
      action_on_notifier :comment
    end

    factory :like_notification do
      action_on_notifier :like
    end
  end
end
