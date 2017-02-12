class PrivateConversation < ApplicationRecord

  # # Assocations
  # ## Participantships/Participants
  has_many :participantships,
    :class_name => "ParticipantshipInPrivateConversation",
    :foreign_key => "private_conversation_id",
    :dependent => :destroy,
    :autosave => true,
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
  scope :most_recent_activity_first,
    -> { order('"private_conversations"."updated_at" DESC') }
  scope :with_associations,
    -> { includes(:messages => :sender).includes(:participants) }

  # finds the conversations between a set of users
  # use like PrivateConversations.find_conversations_between [alice, bob]
  scope :find_conversations_between, -> (users) do
    joins(participantships: :participant).
    where(users: {id: users.pluck(:id)}).
    group("id").
    having("count(\"private_conversations\".\"id\") = ?", users.size)
  end

  # finds conversations that a user is a participant in
  scope :for_user, -> (user) do
    joins(:participantships).
    where(participantship_in_private_conversations: {participant_id: user.id}).
    most_recent_activity_first.
    includes(:participants).
    includes(:most_recent_message)
  end

  # reorders conversations according to passed order
  scope :order_by_updated_at, -> (order) do
    if order.present?
      reorder(:updated_at => order.to_sym)
    end
  end

  # finds conversations updated after the passed time (min_updated_at)
  scope :updated_after, -> (updated_after) do
    if updated_after.present?
      where("private_conversations.updated_at > ?", updated_after).
      distinct
    end
  end

  # applies multiple params
  scope :with_params, -> (updated_after: nil, order: nil) do
    updated_after(updated_after).
    order_by_updated_at(order)
  end

  scope :with_unread_message_count_for, -> (user) do
    joins(:participantships).
    joins("LEFT OUTER JOIN private_messages AS unread_private_messages ON private_conversations.id = unread_private_messages.private_conversation_id and unread_private_messages.created_at > COALESCE(participantship_in_private_conversations.read_at, to_timestamp('0001-01-01 23:59:59', 'YYYY-MM-DD HH24:MI:SS'))").
    merge( PrivateConversation.select("private_conversations.*, count(DISTINCT unread_private_messages.id) as unread_message_count")).
    where(participantship_in_private_conversations: {participant_id: user.id}).
    group(:id)
  end

  # # Accessors
  attr_accessor(:sender, :recipient)
  attr_accessor(:unread_message_count)

  # # Validations
  validates :sender, presence: true, on: :create
  validates :recipient, presence: true, on: :create
  validates :participantships,
    length: {
      is: 2,
      message: "needs exactly two conversation participants"},
    if: "recipient.is_a?(User)", on: :create
  validate :recipient_must_be_a_user, on: :create,
    if: "recipient.present?"
  validate :uniqueness_for_participants, on: :create,
    if: "participantships.present? and recipient.is_a?(User)"
  validate :recipient_can_be_messaged_by_sender, on: :create,
    if: "sender.present? and recipient.present? and recipient.is_a?(User)"
  validate :recipient_and_sender_cannot_be_the_same_person, on: :create,
    if: "sender.present? and recipient.present? and recipient.is_a?(User)"

  # # Callbacks
  after_initialize do
    if attributes['unread_message_count'].present?
      @unread_message_count = attributes['unread_message_count']
    end
  end
  after_initialize :cast_recipient_to_user, if: :new_record?
  after_initialize :add_sender_and_recipient_as_participants, if: :new_record?

  # # Methods

  # adds a participant to the conversation
  def add_participant participant
    self.participantships.build(:participant => participant) if participant.is_a?(User)
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

  # returns the participantship of a given participant
  def participantship_of this_participant
    case this_participant
    when Fixnum
      id_of_this_participant = this_participant
    else
      id_of_this_participant = this_participant.id
    end
    return participantships.
      select{|p| p.participant_id == id_of_this_participant}.first
  end

  # marks the current conversation as read for the participant (only if there
  # are new messages, to avoid unnessecary database insert statements)
  def mark_read_for participant
    if participantship_of( participant ).read_at.nil? or
      (messages.first.present? and
      participantship_of( participant ).read_at < messages.first.created_at)

      participantship_of( participant ).touch(:read_at)

    end
  end

  private

    # Callback: converts recipient from String to User
    def cast_recipient_to_user
      return if recipient.is_a?(User)
      @recipient = User.to_user(@recipient) || @recipient
    end

    # Callback: adds sender and recipient as participants of the conversation
    def add_sender_and_recipient_as_participants
      add_participant sender
      add_participant recipient
    end

    # removes a participant from the conversation
    def remove_participant participant
      self.participantships.each do |p|
        p.mark_for_destruction if p.participant_id == participant.id
      end
    end

    # validates that recipient is of type user
    def recipient_must_be_a_user
      unless recipient.is_a?(User)
        errors.add :recipient, "does not exist or their profile is private"
      end
    end

    def uniqueness_for_participants
      # since :participants is not yet initiated before creation, we need to
      # generate our own hash of user ids
      participation_ids = self.participantships.map {|p| {:id => p.participant_id}}

      if PrivateConversation.find_conversations_between(participation_ids).any?
        errors[:base] << "You already have a conversation with #{recipient.name}"
      end
    end

    def recipient_can_be_messaged_by_sender
      # eager load profile if not already loaded
      if not recipient.association(:profile).loaded?
        ActiveRecord::Associations::Preloader.new.preload(recipient, :profile)
      end

      # validate that recipient can be messaged by sender
      if not recipient.profile.viewable_by? sender
        errors.add :recipient, "does not exist or their profile is private"
      end
    end

    # Conversation sender and recipient must not be the same person
    def recipient_and_sender_cannot_be_the_same_person
      if sender.id == recipient.id
        errors.add :recipient, "can't be yourself"
      end
    end

end
