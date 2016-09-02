FactoryGirl.define do
  factory :friendship do
    association :initiator, factory: :user
    association :acceptor, factory: :user
  end
end
