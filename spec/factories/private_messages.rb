FactoryGirl.define do
  factory :private_message do
    association :conversation, factory: :private_conversation
    sender { conversation.present? ? (conversation.new_record? ? conversation.sender : conversation.participantships.first.participant) : create(:user) }
    content { Faker::Lorem.paragraph }
  end
end
