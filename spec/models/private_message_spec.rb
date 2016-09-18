require 'rails_helper'

RSpec.describe PrivateMessage, type: :model do

  subject(:private_message) { build_stubbed(:private_message) }
  let(:conversation) { private_message.conversation }
  let(:sender) { private_message.sender }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it {
      is_expected.to belong_to(:conversation).
        dependent(false).autosave(true).
        class_name('PrivateConversation').
        with_foreign_key("private_conversation_id").
        inverse_of(:messages)
    }
    it {
      is_expected.to belong_to(:sender).
        dependent(false).
        class_name('User').
        inverse_of(:private_messages_sent)
    }
  end

  describe "scopes" do

    describe "default_scope" do

      it "orders by largest to smallest ID" do
        expect(PrivateMessage.all.to_sql).
          to include('ORDER BY "private_messages"."id" DESC')
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:sender) }
    it { is_expected.to validate_presence_of(:conversation) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(50000) }

    context "custom validations" do
      after { private_message.valid? }

      context "on create" do
        subject(:private_message) { build(:private_message) }
        it { is_expected.to receive(:sender_is_part_of_conversation) }
      end

      context "on update" do
        subject(:private_message) { create(:private_message) }
        it { is_expected.not_to receive(:sender_is_part_of_conversation) }
      end

    end
  end

  describe "callbacks" do

    context "after create" do
      subject(:private_message) { build(:private_message) }
      after { private_message.save }

      it { is_expected.to receive(:touch_conversation) }
      it { is_expected.to receive(:update_read_at_of_sender) }
    end
  end

  describe "#sender_is_part_of_conversation" do
    after { private_message.send(:sender_is_part_of_conversation) }

    it "checks whether the sender is among the conversation participants" do
      participantships = instance_double(Array)
      participant_ids = instance_double(Array)

      expect(conversation).to receive(:participantships) { participantships }
      expect(participantships).to receive(:map) { participant_ids }
      expect(participant_ids).to receive(:include?).with(sender.id)
    end

    context "when sender is among conversation participants" do
      before {
        allow(conversation).
          to receive_message_chain(:participantships, :map, :include?) { true }
      }

      it "does not add an error message" do
        expect(private_message.errors[:base]).not_to receive(:<<)
      end
    end

    context "when sender is not among conversation participants" do
      before {
        allow(conversation).
          to receive_message_chain(:participantships, :map, :include?) { false }
      }

      it "adds an error message" do
        expect(private_message.errors[:base]).to receive(:<<).
          with("#{self.sender.name} (sender) does not belong to this conversation")
      end
    end

  end

  describe "#touch_conversation" do
    after { private_message.send(:touch_conversation) }

    it "touches the conversation" do
      expect(conversation).to receive(:touch)
    end
  end

  describe "#update_read_at_of_sender" do
    subject(:private_message) { create(:private_message) }
    after { private_message.send(:update_read_at_of_sender) }

    it "touches the read_at of participantship of sender" do
      participantship_of_sender =
        instance_double(ParticipantshipInPrivateConversation)

      expect(conversation).
        to receive(:participantship_of).with(sender) { participantship_of_sender }
      expect(participantship_of_sender).to receive(:touch).with(:read_at)
    end
  end

end
