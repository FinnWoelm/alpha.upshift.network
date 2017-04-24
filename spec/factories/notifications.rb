FactoryGirl.define do
  factory :notification do
    association :notifier, factory: :post
    others_acted_before { Time.zone.now - 3.days }

    factory :post_notification do
      action_on_notifier :post
    end

    factory :comment_notification do
      action_on_notifier :comment
    end

    factory :like_notification do
      action_on_notifier :like
    end
  end
end
