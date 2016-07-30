FactoryGirl.define do
  factory :private_message do
    association :conversation, factory: :private_conversation, strategy: :build
    sender { conversation.present? ? (conversation.new_record? ? conversation.sender : conversation.participantships.take.participant) : create(:user) }
    content { Faker::Lorem.paragraph }
  end
end
