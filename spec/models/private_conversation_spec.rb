require 'rails_helper'

RSpec.describe PrivateConversation, type: :model do

  subject(:private_conversation) { build_stubbed(:private_conversation) }
  let(:sender) { private_conversation.sender }
  let(:recipient) { private_conversation.recipient }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it {
      is_expected.to have_many(:participantships).
        dependent(:destroy).autosave(true).
        class_name('ParticipantshipInPrivateConversation').
        with_foreign_key("private_conversation_id").
        inverse_of(:private_conversation)
    }
    it {
      is_expected.to have_many(:participants).dependent(false).
        through(:participantships).source(:participant)
    }
    it {
      is_expected.to have_many(:messages).dependent(:destroy).
        class_name('PrivateMessage').
        with_foreign_key("private_conversation_id").
        inverse_of(:conversation)
    }
    it {
      is_expected.to have_one(:most_recent_message).
        class_name('PrivateMessage').
        with_foreign_key("private_conversation_id")
    }

    describe ":most_recent_message" do
      subject(:private_conversation) { create(:private_conversation) }
      before {
        create_list(:private_message, 3, conversation: private_conversation)
      }
      let!(:most_recent_message) {
        create(:private_message, conversation: private_conversation)
      }
      before { create_list(:private_message, 3) }

      it "returns the most recent message" do
        expect(private_conversation.most_recent_message).
          to eq(most_recent_message)
      end
    end
  end

  describe "scopes" do

    describe ":most_recent_activity_first" do
      after { PrivateConversation.most_recent_activity_first }

      it "orders private conversations by their last updated time" do
        expect(PrivateConversation).to receive(:order).
          with('"private_conversations"."updated_at" DESC')
      end

    end

    describe ":with_associations" do
      before { create(:private_conversation) }
      let(:private_conversation) { PrivateConversation.with_associations.first }

      it "eagerloads messages" do
        expect(private_conversation.association(:messages)).to be_loaded
      end

      it "eagerloads participants" do
        expect(private_conversation.association(:participants)).to be_loaded
      end

    end

    describe ":find_conversations_between" do
      let(:user_one) { create(:user) }
      let(:user_two) { create(:user) }
      subject!(:private_conversation) do
        create(:private_conversation, sender: user_one, recipient: user_two)
      end

      context "when first argument is sender" do
        it "returns the private conversation" do
          expect(PrivateConversation.
            find_conversations_between([user_one, user_two])).
            to eq([private_conversation])
        end
      end

      context "when first argument is recipient" do
        it "returns the private conversation" do
          expect(PrivateConversation.
            find_conversations_between([user_one, user_two])).
            to eq([private_conversation])
        end
      end

      context "when there is no private conversation between two users" do
        it "returns empty array" do
          expect(PrivateConversation.
            find_conversations_between([user_two, create(:user)])).
            to eq([])
        end
      end

    end

  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:sender).on(:create) }
    it { is_expected.to validate_presence_of(:recipient).on(:create) }
    it { is_expected.to validate_presence_of(:messages).on(:create) }
    it { is_expected.to validate_length_of(:participantships).
          with_message("needs exactly two conversation participants")
    }

    context "custom validations" do
      after { private_conversation.valid? }
      it { is_expected.to receive(:recipient_must_be_a_user) }
      it { is_expected.to receive(:uniqueness_for_participants) }
      it { is_expected.to receive(:recipient_can_be_messaged_by_sender) }
      it { is_expected.to receive(:recipient_and_sender_cannot_be_the_same_person) }
    end
  end

  describe "callbacks" do

    context "after initialize" do
      let!(:private_conversation) { PrivateConversation.allocate }
      after { private_conversation.send(:initialize) }

      it { is_expected.to receive(:cast_recipient_to_user) }
      it { is_expected.to receive(:add_sender_and_recipient_as_participants) }
    end
  end

  describe "#add_participant" do
    after { private_conversation.add_participant participant }

    context "when participant is not nil" do
      let(:participant) { build_stubbed(:user) }

      it "builds a participantship" do
        expect(private_conversation.participantships).
          to receive(:build).with(participant: participant)
      end
    end

    context "when participant is nil" do
      let(:participant) { nil }

      it "does not build a participantship" do
        expect(private_conversation.participantships).
          not_to receive(:build).with(participant: participant)
      end
    end
  end

  describe "#participants_other_than" do
    let(:other_participants) { build_stubbed_list(:user, 4) }
    let(:this_participant) { build_stubbed(:user) }
    before {
      private_conversation.participants << other_participants
      private_conversation.participants << this_participant
    }

    context "when this_participant is an ID" do
      it "selects all participants other than this one" do
        expect(private_conversation.participants_other_than(this_participant)).
          to eq(other_participants)
      end
    end

    context "when this_participant is a user" do
      it "selects all participants other than this one" do
        expect(private_conversation.participants_other_than(this_participant)).
          to eq(other_participants)
      end
    end

  end

  describe "#participantship_of" do
    subject(:private_conversation) { build(:private_conversation) }
    let(:other_participants) { build_list(:user, 4) }
    let(:this_participant) { build(:user) }
    before {
      private_conversation.participants << other_participants
      private_conversation.participants << this_participant
      private_conversation.save(validate: false)
    }

    context "when this_participant is an ID" do
      it "selects their participantship" do
        expect(private_conversation.participantship_of(this_participant)).
          to eq(this_participant.participantships_in_private_conversations.first)
      end
    end

    context "when this_participant is a user" do
      it "selects their participantship" do
        expect(private_conversation.participantship_of(this_participant)).
          to eq(this_participant.participantships_in_private_conversations.first)
      end
    end

  end

  describe "#mark_read_for" do
    let(:this_participant) { build(:user) }
    let!(:participantship) { instance_double(ParticipantshipInPrivateConversation) }
    before {
      allow(private_conversation).
        to receive(:participantship_of) { participantship }
    }
    after { private_conversation.mark_read_for this_participant }

    context "when participant has not read conversation" do
      before {
        allow(participantship).to receive_message_chain(:read_at, :nil?) { true }
      }

      it "touches read_at of participant's participantship" do
        expect(participantship).to receive(:touch).with(:read_at)
      end
    end

    context "when latest message is newer than participant's read_at" do
      before {
        allow(private_conversation).
          to receive_message_chain(:messages, :first, :created_at) { Time.now }
        allow(participantship).
          to receive(:read_at) { Time.now - 1.minute }
      }

      it "touches read_at of participant's participantship" do
        expect(participantship).to receive(:touch).with(:read_at)
      end
    end

    context "when participant's read_at is newer than latest message" do
      before {
        allow(private_conversation).
          to receive_message_chain(:messages, :first, :created_at) {
            Time.now - 1.minute
          }
        allow(participantship).
          to receive(:read_at) { Time.now }
      }

      it "does not touch read_at of participant's participantship" do
        expect(participantship).not_to receive(:touch).with(:read_at)
      end
    end
  end

  describe "#cast_recipient_to_user" do
    before do
      private_conversation.recipient = recipient_username
      private_conversation.send(:cast_recipient_to_user)
    end

    context "when recipient is a string" do

      context "when a user exists" do
        let(:recipient_username) { recipient.username}

        it "casts recipient to user" do
          expect(private_conversation.recipient).to be_a(User)
        end
      end

      context "when no user exists" do
        let(:recipient_username) { recipient.username + "abcd"}

        it "retains the original recipient" do
          expect(private_conversation.recipient).to eq(recipient_username)
        end
      end
    end

  end

  describe "#add_sender_and_recipient_as_participants" do
    before do
      private_conversation.participantships = []
      private_conversation.send(:add_sender_and_recipient_as_participants)
    end

    it "adds participant: sender" do
      expect(private_conversation.participantships.map{|p| p.participant_id}).
        to include(sender.id)
    end

    it "adds participant: recipient" do
      expect(private_conversation.participantships.map{|p| p.participant_id}).
        to include(recipient.id)
    end
  end

  describe "#remove_participant" do
    let(:participantship) { private_conversation.participantships.first }
    let(:participant) { participantship.participant }

    it "marks participantship for destruction" do
      expect { private_conversation.send(:remove_participant, participant) }.
        to change { participantship.marked_for_destruction? }.
        from(false).to(true)
    end

    context "when saving private conversation" do
      subject(:private_conversation) { create(:private_conversation) }
      before { private_conversation.send(:remove_participant, participant) }

      it "destructs the participantship" do
        expect { private_conversation.save(validate: false) }.
          to change {
            ParticipantshipInPrivateConversation.
              exists?(id: participantship.id)
          }.
          from(true).to(false)
      end

    end

  end

  describe "#recipient_must_be_a_user" do
    after { private_conversation.send(:recipient_must_be_a_user) }

    context "when recipient is a User" do
      before { private_conversation.recipient = build_stubbed(:user) }

      it "does not add an error message" do
        expect(private_conversation.errors[:recipient]).not_to receive(:<<)
      end
    end

    context "when recipient is a String" do
      before { private_conversation.recipient = "some_string" }

      it "adds an error message" do
        expect(private_conversation.errors[:recipient]).to receive(:<<).
          with("does not exist or their profile is private")
      end
    end

  end

  describe "#uniqueness_for_participants" do
    let(:participant_ids) { [{id: sender.id}, {id: recipient.id}] }
    after { private_conversation.send(:uniqueness_for_participants) }

    it "checks whether conversations between these participants exists" do
      conversations_between_participants = class_double(PrivateConversation)
      expect(PrivateConversation).to receive(:find_conversations_between).
        with(participant_ids) { conversations_between_participants }
      expect(conversations_between_participants).to receive(:any?)
    end

    context "when a conversation between these participants exists" do
      before {
        allow(PrivateConversation).
          to receive_message_chain(:find_conversations_between, :any?) { true }
      }

      it "adds an error message" do
        expect(private_conversation.errors[:base]).to receive(:<<).
          with("You already have a conversation with #{recipient.name}")
      end
    end

    context "when a conversation between these participants does not exist" do
      before {
        allow(PrivateConversation).
          to receive_message_chain(:find_conversations_between, :any?) { false }
      }

      it "does not add an error message" do
        expect(private_conversation.errors[:base]).not_to receive(:<<)
      end
    end

  end

  describe "#recipient_can_be_messaged_by_sender" do
    after { private_conversation.send(:recipient_can_be_messaged_by_sender) }

    it "checks whether recipient profile is viewable by sender" do
      recipient_profile = instance_double(Profile)
      expect(recipient).to receive(:profile) { recipient_profile }
      expect(recipient_profile).to receive(:viewable_by?).with(sender)
    end

    context "when recipient profile is viewable by sender" do
      before {
        allow(recipient).
          to receive_message_chain(:profile, :viewable_by?) { true }
      }

      it "does not add an error message" do
        expect(private_conversation.errors[:recipient]).not_to receive(:<<)
      end
    end

    context "when recipient profile is not viewable by sender" do
      before {
        allow(recipient).
          to receive_message_chain(:profile, :viewable_by?) { false }
      }

      it "adds an error message" do
        expect(private_conversation.errors[:recipient]).to receive(:<<).
          with("does not exist or their profile is private")
      end
    end

  end

  describe "#recipient_and_sender_cannot_be_the_same_person" do
    after {
      private_conversation.send(:recipient_and_sender_cannot_be_the_same_person)
    }

    context "when IDs of sender and recipient are not identical" do
      before { sender.id = recipient.id + 1 }

      it "does not add an error message" do
        expect(private_conversation.errors[:recipient]).not_to receive(:<<)
      end
    end

    context "when IDs of sender and recipient are identical" do
      before { sender.id = recipient.id }

      it "adds an error message" do
        expect(private_conversation.errors[:recipient]).to receive(:<<).
          with("can't be yourself")
      end
    end

  end

end
