require 'rails_helper'

RSpec.describe PrivateMessage, type: :model do

  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_length_of(:content).is_at_most(50000) }

  it "has a valid factory" do
    expect(build(:private_message)).to be_valid
  end

  it "is invalid without sender" do
    expect(build(:private_message, :sender => nil)).to be_invalid
  end

  it "is invalid without conversation" do
    expect(build(:private_message, :conversation => nil)).to be_invalid
  end

  it "is invalid if conversation is invalid" do
    @conversation = build(:private_conversation)
    @message = build(:private_message, :conversation => @conversation, :sender => @conversation.sender)

    # set the recipient to invisible and it should fail to validate
    @conversation.recipient.profile.is_private!
    expect(@message).to be_invalid
    expect(@message.errors.messages[:"conversation.recipient"]).
      to include("does not exist or their profile is private.")
    expect(@conversation.errors.full_messages).
      to include("Recipient does not exist or their profile is private.")
  end

  it "creates the conversation if it does not yet exist" do
    @conversation = build(:private_conversation)
    @message = create(:private_message, :conversation => @conversation, :sender => @conversation.sender)

    expect(PrivateMessage.all.size).to eq(1)
    expect(PrivateConversation.all.size).to eq(1)
  end

  it "is invalid if the sender is not part of the conversation" do
    message = build(:private_message, :sender => create(:user))
    expect(message).to be_invalid
    expect(message.errors.full_messages).
      to include("#{message.sender.name} (sender) does not belong to this conversation.")
  end

end
