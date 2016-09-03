require 'rails_helper'

RSpec.describe ParticipantshipInPrivateConversation, type: :model do

  subject(:participantship) { build(:participantship_in_private_conversation) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:participant).dependent(false).class_name('User') }
    it { is_expected.to belong_to(:private_conversation).dependent(false) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:participant) }
    it { is_expected.to validate_presence_of(:private_conversation) }

    context "custom validations" do
      after { participantship.valid? }

      context "on create" do
        subject(:participantship) { build(:participantship_in_private_conversation) }

        it { is_expected.to receive(:uniqueness_for_participant_and_private_conversation) }
        it { is_expected.not_to receive(:participant_cannot_change) }
        it { is_expected.not_to receive(:private_conversation_cannot_change) }
      end

      context "on update" do
        subject(:participantship) { create(:participantship_in_private_conversation) }

        it { is_expected.not_to receive(:uniqueness_for_participant_and_private_conversation) }
        it { is_expected.to receive(:participant_cannot_change) }
        it { is_expected.to receive(:private_conversation_cannot_change) }
      end

    end
  end

  describe "#uniqueness_for_participant_and_private_conversation" do
    let(:participant)   { participantship.participant }
    let(:private_conversation) { participantship.private_conversation }
    after { participantship.send(:uniqueness_for_participant_and_private_conversation) }

    it "checks whether a participantship with same participant and conversation exists" do
      expect(ParticipantshipInPrivateConversation).to receive(:exists?).with({
        participant: participant,
        private_conversation: private_conversation
      })
    end

    context "when participantship with participant and conversation exists" do
      before { allow(ParticipantshipInPrivateConversation).to receive(:exists?) { true } }

      it "adds an error message" do
        expect(participantship.errors[:base]).to receive(:<<).
          with("An association between this participant and this conversation already exists.")
      end

    end

    context "when participantship with participant and conversation does not exists" do
      before { allow(ParticipantshipInPrivateConversation).to receive(:exists?) { false } }

      it "does not add an error message" do
        expect(participantship.errors[:base]).not_to receive(:<<)
      end

    end
  end

  describe "#participant_cannot_change" do
    after { participantship.send(:participant_cannot_change) }

    it "checks whether participant has changed" do
      changed_attributes = instance_double(Array)
      expect(participantship).to receive(:changed) { changed_attributes }
      expect(changed_attributes).to receive(:include?).with("participant_id")
    end

    context "when participant has changed" do
      before { allow(participantship).to receive_message_chain(:changed, :include?) { true } }

      it "adds an error message" do
        expect(participantship.errors[:participant]).to receive(:<<).
          with("cannot be updated.")
      end

    end

    context "when participant has not changed" do
      before { allow(participantship).to receive_message_chain(:changed, :include?) { false } }

      it "does not add an error message" do
        expect(participantship.errors[:participant]).not_to receive(:<<)
      end

    end
  end

  describe "#private_conversation_cannot_change" do
    after { participantship.send(:private_conversation_cannot_change) }

    it "checks whether private conversation has changed" do
      changed_attributes = instance_double(Array)
      expect(participantship).to receive(:changed) { changed_attributes }
      expect(changed_attributes).to receive(:include?).with("private_conversation_id")
    end

    context "when private conversation has changed" do
      before { allow(participantship).to receive_message_chain(:changed, :include?) { true } }

      it "adds an error message" do
        expect(participantship.errors[:private_conversation]).to receive(:<<).
          with("cannot be updated.")
      end

    end

    context "when private conversation has not changed" do
      before { allow(participantship).to receive_message_chain(:changed, :include?) { false } }

      it "does not add an error message" do
        expect(participantship.errors[:private_conversation]).not_to receive(:<<)
      end

    end
  end

end
