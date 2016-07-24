class ParticipantshipInPrivateConversation < ApplicationRecord
  belongs_to :participant, :class_name => "User", :optional => false
  belongs_to :private_conversation, :autosave => true, :optional => false

  # # Validations
  # make sure that this association between participant and conversation is
  # unique
  validate :participantship_is_unique_for_participant_and_private_conversation,
    if: "participant.present? and private_conversation.present?"

  protected
    def participantship_is_unique_for_participant_and_private_conversation
      if ParticipantshipInPrivateConversation.find_by participant: self.participant, private_conversation: self.private_conversation
        errors[:base] << "An association between this participant and this conversation already exists."
      end
    end
end
