require 'rails_helper'

RSpec.describe User, type: :model do

  subject(:user) { build(:user) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  it { is_expected.to have_secure_password }

  describe "associations" do
    it { is_expected.to have_one(:profile).dependent(:destroy).
      inverse_of(:user)}
    it { is_expected.to have_many(:posts).dependent(:destroy).
      with_foreign_key("author_id")}
    it { is_expected.to have_many(:comments).dependent(:destroy).
      with_foreign_key("author_id")}

    it { is_expected.to have_many(:likes).dependent(:destroy).
      with_foreign_key("liker_id")}

    it { is_expected.to have_many(:participantships_in_private_conversations).
      dependent(:destroy).class_name("ParticipantshipInPrivateConversation").
      with_foreign_key("participant_id").inverse_of(:participant) }
    it { is_expected.to have_many(:private_conversations).dependent(false).
      through(:participantships_in_private_conversations).
      source(:private_conversation) }

    it { is_expected.to have_many(:private_messages_sent).dependent(:destroy).
      class_name("PrivateMessage").with_foreign_key("sender_id").
      inverse_of(:sender) }

    it { is_expected.to have_many(:friendship_requests_sent).
      dependent(:destroy).class_name("FriendshipRequest").
      with_foreign_key("sender_id") }
    it { is_expected.to have_many(:friendship_requests_received).
      dependent(:destroy).class_name("FriendshipRequest").
      with_foreign_key("recipient_id") }

    it { is_expected.to have_many(:friendships_initiated).
      dependent(:destroy).class_name("Friendship").
      with_foreign_key("initiator_id") }
    it { is_expected.to have_many(:friendships_accepted).
      dependent(:destroy).class_name("Friendship").
      with_foreign_key("acceptor_id") }

    it { is_expected.to have_many(:friends_found).dependent(false).
      through(:friendships_initiated).source(:acceptor) }
    it { is_expected.to have_many(:friends_made).dependent(false).
      through(:friendships_accepted).source(:initiator) }

  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:profile) }
    it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(26) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }

    context "validates format of username" do
      it "must not contain special characters" do
        user.username = "a*<>$@/r"
        is_expected.to be_invalid
      end

      it "must not begin with an underscore" do
        user.username = "_" + user.username
        is_expected.to be_invalid
      end

      it "must not end with an underscore" do
        user.username += "_"
        is_expected.to be_invalid
      end

    end
  end

  describe "#to_param" do
    it "returns the username" do
      expect(user.to_param).to eq(user.username)
    end
  end

  describe "#friends" do
    let(:friends_made) { build_stubbed_list(:user, 3) }
    let(:friends_found) { build_stubbed_list(:user, 3) }
    before do
      user.friends_made = friends_made
      user.friends_found = friends_found
    end

    it "returns friends found and friends made" do
      expect(user.friends).to match_array(friends_made + friends_found)
    end

  end

  describe "#has_friendship_with?" do
    let(:other_user) { build_stubbed(:user) }

    context "when user has friendship" do
      before { allow(user).to receive(:friends) { [other_user] } }

      it "returns true" do
        is_expected.to have_friendship_with other_user
      end
    end

    context "when user does not have friendship" do
      before { allow(user).to receive(:friends) { [] } }

      it "returns false" do
        is_expected.not_to have_friendship_with other_user
      end
    end
  end

  describe "#has_received_friend_request_from?" do
    let(:other_user) { build(:user) }

    context "when user has received friend request" do
      before do
        create(:friendship_request, :sender => other_user, :recipient => user)
      end

      it "returns true" do
        is_expected.to have_received_friend_request_from other_user
      end
    end

    context "when user does not have received friend request" do
      before { FriendshipRequest.destroy_all }

      it "returns false" do
        is_expected.not_to have_received_friend_request_from other_user
      end
    end
  end

  describe "#has_sent_friend_request_to?" do
    let(:other_user) { build(:user) }

    context "when user has sent friend request" do
      before do
        create(:friendship_request, :sender => user, :recipient => other_user)
      end

      it "returns true" do
        is_expected.to have_sent_friend_request_to other_user
      end
    end

    context "when user does not have sent friend request" do
      before { FriendshipRequest.destroy_all }

      it "returns false" do
        is_expected.not_to have_sent_friend_request_to other_user
      end
    end
  end

  describe "#unread_private_conversations" do
    before { user.save }
    let!(:conversations) { create_list(:private_conversation, 5, :sender => user) }

    it "returns conversations in the order of most recent activity" do
      expect(user.private_conversations).
      to receive(:most_recent_activity_first) { user.private_conversations }
      user.unread_private_conversations
    end

    it "returns conversations that were never read" do
      set_last_read_of_participantships { nil }
      expect(user.unread_private_conversations).to match_array(conversations)
    end

    it "returns conversations that are unread" do
      set_last_read_of_participantships do |p|
        p.private_conversation.updated_at - 1.second
      end
      expect(user.unread_private_conversations).to match_array(conversations)
    end

    it "does not return read conversations" do
      set_last_read_of_participantships{ |p| p.private_conversation.updated_at }
      expect(user.unread_private_conversations).to eq( [] )
    end

    def set_last_read_of_participantships
      user.participantships_in_private_conversations.each do |participantship|
        participantship.update_attributes(read_at: yield(participantship) )
      end
    end

  end

  describe ".to_user" do

    context "when input is a string" do
      let(:user) { create(:user) }

      it "returns the user" do
        expect(User.to_user(user.username)).to eq(user)
      end
    end

    context "when input is a User" do
      let(:user) { create(:user) }

      it "returns the user" do
        expect(User.to_user(user)).to eq(user)
      end
    end

    context "when input is a number" do
      it "raises an error" do
        expect{ User.to_user(1) }.to raise_error(ArgumentError)
      end
    end

    context "when input is nil" do
      it "returns nil" do
        expect(User.to_user(nil)).to be_nil
      end
    end

  end

end
