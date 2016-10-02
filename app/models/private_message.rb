class PrivateMessage < ApplicationRecord

  # # Associations
  # Private Conversation
  belongs_to :conversation, :class_name => "PrivateConversation",
    :foreign_key => "private_conversation_id",
    :inverse_of => :messages,
    :autosave => true,
    :validate => false
  # User
  belongs_to :sender, :class_name => "User",
    :inverse_of => :private_messages_sent

  # # Scopes
  default_scope -> { order('"private_messages"."id" DESC') }

  # # Validations
  validates :conversation, presence: true
  validates :sender, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 50000 }
  validate :sender_is_part_of_conversation, on: :create,
    if: "sender.present? and conversation.present?"

  # # Callbacks
  # Touches the conversation that this message belongs to so that we know there
  # is a new message in the conversation.
  # Warning: This MUST precede the :update_read_at_of_sender callback, otherwise
  # the conversation will appear as unread to the sender of the message
  after_create :touch_conversation

  # updates the read_at attribute of the sender's participation in the
  # conversaton that this private message belongs to. This is used to prevent
  # conversations from appearing as unread to the user who sent the message
  after_create :update_read_at_of_sender

  private
    # Validation: Sender must be part of the conversation to send messages
    def sender_is_part_of_conversation

      participant_ids = conversation.participantships.map {|p| p.participant_id}

      if not participant_ids.include? sender.id
        errors[:base] << "#{self.sender.name} (sender) does not belong to this conversation"
      end
    end

    # Touches the conversation that this message belongs to so that we know there
    # is a new message in the conversation.
    # Warning: This MUST precede the :update_read_at_of_sender callback, otherwise
    # the conversation will appear as unread to the sender of the message
    def touch_conversation
      conversation.touch
    end

    # updates the read_at attribute of the
    # participantship_in_private_conversations table for the sender and this
    # conversation. So that the new message won't be marked as unread for the
    # sender
    def update_read_at_of_sender
      conversation.participantship_of( sender ).touch(:read_at)
    end

end
