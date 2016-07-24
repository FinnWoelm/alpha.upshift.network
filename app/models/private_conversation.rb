class PrivateConversation < ApplicationRecord

  # # Relations
  has_many :participantships,
    :class_name => "ParticipantshipInPrivateConversation",
    :foreign_key => "private_conversation_id",
    :dependent => :destroy,
    :inverse_of => :private_conversation
  has_many :participants,
    :through => :participantships,
    :source => :participant

  # # Scopes
  default_scope -> { order('"private_conversations"."created_at" ASC') }

  # finds the conversations between a set of users
  # use like PrivateConversations.find_conversations_between [alice, bob]
  scope :find_conversation_between,
    ->(users) {
      joins(participantships: :participant).
      where(users: {id: users.pluck(:id)}).
      group("id").
      having("count(\"private_conversations\".\"id\") = ?", users.size)
    }

  # # Accessors
  attr_reader(:sender, :recipient)

  # # Validations
  validates :sender, presence: true, on: :create
  validates :recipient, presence: true, on: :create
  validates :participantships,
    length: {
      is: 2,
      message: "needs exactly two conversation participants"}
  validate :private_conversation_is_unique_for_participants, on: :create,
    if: "participantships.present?"
  validate :recipient_can_be_messaged_by_sender, on: :create,
    if: "sender.present? and recipient.present?"

  # # Methods

  def sender=(user)
    self.remove_participant @sender if @sender
    self.add_participant user
    @sender = user
  end

  def recipient=(user)
    self.remove_participant @recipient if @recipient
    self.add_participant user
    @recipient = user
  end

  protected
    # adds a participant to the conversation
    def add_participant participant
      self.participantships.build(:participant => participant)
    end

    # removes a participant from the conversation
    def remove_participant participant
      self.participantships.each do |p|
        p.mark_for_destruction if p.participant_id == participant.id
      end
    end

    def private_conversation_is_unique_for_participants
      # since :participants is not yet initiated before creation, we need to
      # generate our own hash of user ids
      participation_ids = self.participantships.map {|p| {:id => p.participant_id}}

      if PrivateConversation.find_conversations_between(participation_ids).any?
        errors[:base] << "You already have a conversation with #{recipient.name}."
      end
    end

    def recipient_can_be_messaged_by_sender
      if not recipient.profile.can_be_seen_by? sender
        errors.add :recipient, "does not exist or their profile is private."
      end
    end
end
