class ParticipantshipInPrivateConversation < ApplicationRecord
  belongs_to :participant, :class_name => "User", :optional => false
  belongs_to :private_conversation, :optional => false, :validate => false

  # # Validations
  # make sure that this association between participant and conversation is
  # unique
  validate :participantship_is_unique_for_participant_and_private_conversation,
    if: "participant.present? and private_conversation.present?"

  protected
    def participantship_is_unique_for_participant_and_private_conversation
      return unless self.private_conversation.id
      if ParticipantshipInPrivateConversation.where(participant: self.participant, private_conversation: self.private_conversation).exists?
        errors[:base] << "An association between this participant and this conversation already exists."
      end
    end
end
