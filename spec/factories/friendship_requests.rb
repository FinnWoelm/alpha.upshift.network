FactoryGirl.define do
  factory :friendship_request do
    association :sender, factory: :user
    association :recipient, factory: :user
  end
end
