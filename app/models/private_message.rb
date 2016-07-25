class PrivateMessage < ApplicationRecord

  # # Associations
  # Private Conversation
  belongs_to :conversation, :class_name => "PrivateConversation",
    :foreign_key => "private_conversation_id",
    :inverse_of => :messages,
    :optional => false,
    :touch => true
  # User
  belongs_to :sender, :class_name => "User",
    :inverse_of => :private_messages_sent,
    :optional => false

  # # Validations
  validates :content, presence: true
  validates :content, length: { maximum: 50000 }

  # # Scopes
  default_scope -> { order('"private_messages"."id" DESC') }

end
