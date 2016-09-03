FactoryGirl.define do
  factory :participantship_in_private_conversation do
    association :participant, factory: :user
    association :private_conversation
  end
end
