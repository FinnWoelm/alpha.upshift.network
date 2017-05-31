class ParticipantshipInPrivateConversation < ApplicationRecord

  # # Associations
  belongs_to :participant, :class_name => "User"
  belongs_to :private_conversation

  # # Validations
  validates :participant, presence: true
  validates :private_conversation, presence: true
  validate :uniqueness_for_participant_and_private_conversation,
    if: "participant.present? and private_conversation.present?", on: :create
  validate :participant_cannot_change, on: :update
  validate :private_conversation_cannot_change, on: :update


  # callbacks
  # destroy the private conversation if only one participant remains
  after_destroy do
    if ParticipantshipInPrivateConversation.where(:private_conversation_id => self.private_conversation_id).count == 1
      PrivateConversation.find(self.private_conversation_id).destroy
    end
  end

  private

    # validates that this participantship is unique
    def uniqueness_for_participant_and_private_conversation
      return unless self.private_conversation.id
      if ParticipantshipInPrivateConversation.exists?(participant: self.participant, private_conversation: self.private_conversation)
        errors[:base] << "An association between this participant and this conversation already exists."
      end
    end

    # validates that participant was not updated
    def participant_cannot_change
      if self.changed.include? "participant_id"
        errors[:participant] << "cannot be updated."
      end
    end

    # validates that conversation was not updated
    def private_conversation_cannot_change
      if self.changed.include? "private_conversation_id"
        errors[:private_conversation] << "cannot be updated."
      end
    end
end
