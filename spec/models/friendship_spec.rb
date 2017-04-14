require 'rails_helper'

RSpec.describe Friendship, type: :model do

  subject(:friendship) { build_stubbed(:friendship) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:initiator).dependent(false).class_name('User') }
    it { is_expected.to belong_to(:acceptor).dependent(false).class_name('User') }
  end

  describe "scopes" do

    describe ":find_friendships_between" do
      let(:user_one) { create(:user) }
      let(:user_two) { create(:user) }
      subject!(:friendship) do
        create(:friendship, initiator: user_one, acceptor: user_two)
      end

      context "when first argument is initiator" do
        it "returns the friendship" do
          expect(Friendship.find_friendships_between(user_one, user_two)).
            to eq([friendship])
        end
      end

      context "when first argument is acceptor" do
        it "returns the friendship" do
          expect(Friendship.find_friendships_between(user_two, user_one)).
            to eq([friendship])
        end
      end

      context "when there is no friendship between two users" do
        it "returns empty array" do
          expect(Friendship.find_friendships_between(user_two, create(:user))).
            to eq([])
        end
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:initiator) }
    it { is_expected.to validate_presence_of(:acceptor) }

    context "custom validations" do
      after { friendship.valid? }
      it { is_expected.to receive(:friendship_must_be_unique) }
    end
  end

  describe "callbacks" do
    subject(:friendship) { build(:friendship) }

    context "after create" do
      after { friendship.save }

      it { is_expected.to receive(:destroy_friendship_requests) }
    end
  end

  describe ".friends_ids_for" do
    let!(:user) { create(:user) }
    let!(:friends_found) { create_list(:friendship, 3, :initiator => user) }
    let!(:friends_made) { create_list(:friendship, 3, :acceptor => user) }
    let(:ids_of_friends) { friends_found.pluck(:acceptor_id) + friends_made.pluck(:initiator_id) }

    it "returns IDs of both friends made and found" do
      expect(Friendship.friends_ids_for(user)).to match_array(ids_of_friends)
    end
  end

  describe "#friendship_must_be_unique" do
    let(:initiator) { friendship.initiator }
    let(:acceptor)  { friendship.acceptor }
    after do
      friendship.send(:friendship_must_be_unique)
    end

    it "queries for friendships between initiator and acceptor" do
      expect(Friendship).to receive(:find_friendships_between).
        with(initiator, acceptor) { [] }
    end

    context "when friendship already exists" do
      before do
        allow(Friendship).
          to receive(:find_friendships_between) { [friendship] }
      end

      it "adds an error message" do
        expect(friendship.errors[:base]).to receive(:<<).
          with("A friendship between #{initiator.name} and #{acceptor.name} " +
            "already exists.")
      end
    end

    context "when friendship does not yet exist" do
      before do
        allow(Friendship).
          to receive(:find_friendships_between) { [] }
      end

      it "does not add an error message" do
        expect(friendship.errors[:base]).not_to receive(:<<)
      end
    end
  end

  describe "#destroy_friendship_requests" do
    let(:initiator) { friendship.initiator }
    let(:acceptor)  { friendship.acceptor }
    after do
      friendship.send(:destroy_friendship_requests)
    end

    it "queries for friendship requests between initiator and acceptor" do
      expect(FriendshipRequest).to receive(:find_friendship_requests_between).
        with(initiator, acceptor) { FriendshipRequest.none }
    end

    it "deletes all friendship requests retrieved" do
      retrieved_requests = double
      allow(FriendshipRequest).to receive(:find_friendship_requests_between) { retrieved_requests }
      expect(retrieved_requests).to receive(:destroy_all)
    end

  end

end
