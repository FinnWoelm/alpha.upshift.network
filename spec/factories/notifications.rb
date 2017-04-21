FactoryGirl.define do
  factory :notification do
    association :notifier, factory: :post
    action_on_notifier :post
    others_acted_before { Time.zone.now - 3.days }
  end
end
