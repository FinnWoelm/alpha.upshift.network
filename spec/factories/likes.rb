FactoryGirl.define do
  factory :like do
    association :liker, factory: :user
    association :likable, factory: :post
  end
end
