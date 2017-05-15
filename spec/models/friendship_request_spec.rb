require 'rails_helper'
require 'models/shared_examples/examples_for_notifying.rb'

RSpec.describe FriendshipRequest, type: :model do

  subject(:friendship_request) { build_stubbed(:friendship_request) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  it_behaves_like "a notifying object" do
    subject(:notifier) { build(:friendship_request) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:sender).dependent(false).class_name('User') }
    it { is_expected.to belong_to(:recipient).dependent(false).
      class_name('User') }
  end

  describe "scopes" do

    describe ":find_friendship_requests_between" do
      let(:user_one) { create(:user) }
      let(:user_two) { create(:user) }
      subject!(:friendship_request) do
        create(:friendship_request, sender: user_one, recipient: user_two)
      end

      context "when first argument is sender" do
        it "returns the friendship request" do
          expect(FriendshipRequest.
            find_friendship_requests_between(user_one, user_two)).
            to eq([friendship_request])
        end
      end

      context "when first argument is recipient" do
        it "returns the friendship request" do
          expect(FriendshipRequest.
            find_friendship_requests_between(user_two, user_one)).
            to eq([friendship_request])
        end
      end

      context "when there is no friendship request between two users" do
        it "returns empty array" do
          expect(FriendshipRequest.
            find_friendship_requests_between(user_two, create(:user))).
            to eq([])
        end
      end

    end

  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:sender) }
    it { is_expected.to validate_presence_of(:recipient) }

    context "custom validations" do
      after { friendship_request.valid? }

      it { is_expected.to receive(:recipient_profile_must_be_viewable_by_sender) }
      it { is_expected.to receive(:friendship_request_is_unique) }
      it { is_expected.to receive(:friendship_must_not_already_exist) }

    end
  end

  describe "#create_notification" do
    let(:friendship_request) { build(:friendship_request) }
    let(:friendship_request_notification) do
      Notification.find_by(
        :notifier => friendship_request.recipient,
        :action_on_notifier => "friendship_request"
      )
    end

    it "creates a notification" do
      friendship_request.save
      expect(Notification::Action).
        to exist(
          notification: friendship_request_notification,
          actor: friendship_request.sender,
          created_at: friendship_request.created_at)
    end

    context "when notification for friend requests does not exist" do
      before { Notification::Subscription.destroy_all }

      it "creates the notifaction" do
        friendship_request.save
        expect(friendship_request_notification).to be_present
      end

      it "subscribes the user to the notification" do
        friendship_request.save
        expect(Notification::Subscription).
          to exist(
            notification: friendship_request_notification,
            subscriber: friendship_request.recipient,
            created_at: friendship_request.created_at
          )
      end
    end
  end

  describe "#destroy_notification" do
    let(:friendship_request) { build(:friendship_request) }
    let(:friendship_request_notification) do
      Notification.find_by(
        :notifier => friendship_request.recipient,
        :action_on_notifier => "friendship_request"
      )
    end

    context "when other requests exist" do
      before do
        friendship_request.save
        create(:friendship_request, :recipient => friendship_request.recipient)
      end

      it "re-initalizes actions on the notification" do
        allow(Notification).to receive(:find_by).and_return(friendship_request_notification)
        expect(friendship_request_notification).to receive(:reinitialize_actions)
        friendship_request.destroy
      end
    end

    context "when other requests do not exist" do
      before do
        FriendshipRequest.destroy_all
        friendship_request.save
      end

      it "destroys the like notification" do
        friendship_request.destroy
        expect(friendship_request_notification).not_to be_present
      end
    end
  end

  describe "#recipient_profile_must_be_viewable_by_sender" do
    let(:recipient) { friendship_request.recipient }
    let(:sender)    { friendship_request.sender }
    after do
      friendship_request.send(:recipient_profile_must_be_viewable_by_sender)
    end

    it "checks whether the recipient profile is viewable by the sender" do
      expect(recipient).to receive(:viewable_by?).with(sender)
    end

    context "when sender cannot see recipient" do
      before { allow(recipient).to receive(:viewable_by?) { false } }

      it "adds an error message" do
        expect(friendship_request.errors[:base]).to receive(:<<).
          with("User does not exist or profile is private")
      end
    end

    context "when sender can see recipient" do
      before { allow(recipient).to receive(:viewable_by?) { true } }

      it "does not add an error message" do
        expect(friendship_request.errors[:base]).not_to receive(:<<)
      end
    end
  end

  describe "#friendship_request_is_unique" do
    let(:recipient) { friendship_request.recipient }
    let(:sender)    { friendship_request.sender }
    after do
      friendship_request.send(:friendship_request_is_unique)
    end

    it "queries for friendship requests between sender and recipient" do
      expect(FriendshipRequest).to receive(:find_friendship_requests_between).
        with(sender, recipient) { [] }
    end

    context "when friendship request already exists" do
      before do
        allow(FriendshipRequest).
          to receive(:find_friendship_requests_between) { [friendship_request] }
      end

      it "adds an error message" do
        expect(friendship_request.errors[:base]).to receive(:<<).
          with("A friendship request between #{sender.name} and " +
            "#{recipient.name} already exists.")
      end
    end

    context "when friendship request does not yet exist" do
      before do
        allow(FriendshipRequest).
          to receive(:find_friendship_requests_between) { [] }
      end

      it "does not add an error message" do
        expect(friendship_request.errors[:base]).not_to receive(:<<)
      end
    end
  end

  describe "#friendship_must_not_already_exist" do
    let(:recipient) { friendship_request.recipient }
    let(:sender)    { friendship_request.sender }
    after do
      friendship_request.send(:friendship_must_not_already_exist)
    end

    it "checks whether the sender already has a friendship with recipient" do
      expect(sender).to receive(:has_friendship_with?).with(recipient)
    end

    context "when sender has friendship with recipient" do
      before { allow(sender).to receive(:has_friendship_with?) { true } }

      it "adds an error message" do
        expect(friendship_request.errors[:base]).to receive(:<<).
          with("You are already friends with #{recipient.name}")
      end
    end

    context "when sender does not have friendship with recipient" do
      before { allow(sender).to receive(:has_friendship_with?) { false } }

      it "does not add an error message" do
        expect(friendship_request.errors[:base]).not_to receive(:<<)
      end
    end
  end

end
