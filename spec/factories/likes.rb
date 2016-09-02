FactoryGirl.define do
  factory :like do
    association :liker, factory: :user
  end
end
