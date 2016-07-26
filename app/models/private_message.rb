class PrivateMessage < ApplicationRecord

  # # Associations
  # Private Conversation
  belongs_to :conversation, :class_name => "PrivateConversation",
    :foreign_key => "private_conversation_id",
    :inverse_of => :messages,
    :optional => false,
    :autosave => true
  # User
  belongs_to :sender, :class_name => "User",
    :inverse_of => :private_messages_sent,
    :optional => false

  # # Validations
  validates :content, presence: true
  validates :content, length: { maximum: 50000 }

  # # Scopes
  default_scope -> { order('"private_messages"."id" DESC') }

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

  protected
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
      conversation.participantships.each do |participantship|
        if participantship.participant_id == sender.id
          participantship.touch(:read_at)
        end
      end
    end

end
