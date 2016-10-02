FactoryGirl.define do
  factory :private_conversation do
    sender { create(:user) }
    recipient { create(:user) }

    after(:build, :stub) do |conversation|
      conversation.add_participant conversation.sender
      conversation.add_participant conversation.recipient
      
      conversation.messages.build(
        attributes_for(:private_message, sender: conversation.sender)
      )
    end
  end
end
