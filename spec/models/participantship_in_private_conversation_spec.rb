require 'rails_helper'

RSpec.describe ParticipantshipInPrivateConversation, type: :model do

  it "does not allow duplicate associations between participant and conversation" do

    conversation = create(:private_conversation)

    duplicate_participantship =
      ParticipantshipInPrivateConversation.new(
        :participant => conversation.participants.first,
        :private_conversation => conversation
      )

    expect(duplicate_participantship).not_to be_valid
    expect(duplicate_participantship.errors.full_messages).
      to include("An association between this participant and this conversation already exists.")

  end

end
