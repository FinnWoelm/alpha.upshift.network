class PrivateConversation < ApplicationRecord

  # # Assocations
  # ## Participantships/Participants
  has_many :participantships,
    :class_name => "ParticipantshipInPrivateConversation",
    :foreign_key => "private_conversation_id",
    :dependent => :destroy,
    :inverse_of => :private_conversation
  has_many :participants,
    :through => :participantships,
    :source => :participant

  # ## Private Messages
  has_many :messages,
    :class_name => "PrivateMessage",
    :foreign_key => "private_conversation_id",
    :dependent => :destroy,
    :inverse_of => :conversation
  has_one :most_recent_message, -> {
      self.select_values = ["DISTINCT ON(private_messages.private_conversation_id) private_messages.*"]
      reorder('private_messages.private_conversation_id, private_messages.id DESC')
    },
    :class_name => "PrivateMessage",
    :foreign_key => "private_conversation_id"

  # # Scopes
  default_scope -> { includes(:participants).order('"private_conversations"."updated_at" DESC') }

  # finds the conversations between a set of users
  # use like PrivateConversations.find_conversations_between [alice, bob]
  scope :find_conversations_between,
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
  validate :recipient_and_sender_must_not_be_the_same_person, on: :create,
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

  # returns a list of participants that exclude the participant (object or ID)
  # supplied by the this_participant argument
  def participants_other_than this_participant
    case this_participant
    when Fixnum
      id_of_this_participant = this_participant
    else
      id_of_this_participant = this_participant.id
    end
    return participants.select {|p| p.id != id_of_this_participant}
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

    # Conversation sender and recipient must not be the same person
    def recipient_and_sender_must_not_be_the_same_person
      if sender.id == recipient.id
        errors.add :recipient, "cannot be yourself."
      end
    end

end
