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

  # # Accessors
  # We use the recipient_username and recipient accessors to convert from the
  # username that we receive in the params to the User object that we need to
  # build the conversation
  attr_accessor(:recipient_username)
  def recipient=(val)
    if val.is_a? String
      @recipient_username = val
    elsif val.is_a? User
      @recipient_username = val.username
    end
  end
  def recipient
    User.find_by(:username => self.recipient_username)
  end

  # # Validations
  validates :conversation, presence: true
  validates :sender, presence: true
  validates :content, presence: true
  validates :content, length: { maximum: 50000 }
  validate :sender_is_part_of_conversation, on: :create,
    if: "sender.present? and conversation.present?"

  # # Callbacks
  # Sets the recipient username on the basis of this message's conversation
  # (only if conversation is eager loaded and not a new record, for performance
  # reasons)
  after_initialize :set_recipient_username, if: "sender_id.present?"

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

    # Callback: After Initialize
    # Sets the recipient username on the basis of this message's conversation
    # (only if conversation is eager loaded and not a new record, for performance
    # reasons)
    def set_recipient_username
      if self.association(:conversation).loaded? and not self.conversation.new_record?
        @recipient_username =
          self.conversation.participants_other_than(self.sender.id).first.username
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
