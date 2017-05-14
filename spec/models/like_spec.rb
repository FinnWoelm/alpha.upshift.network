require 'rails_helper'
require 'models/shared_examples/examples_for_notifying.rb'

RSpec.describe Like, type: :model do

  subject(:like) { build(:like) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  it_behaves_like "a notifying object" do
    subject(:notifier) { build(:like) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:liker).dependent(false).class_name('User') }
    it { is_expected.to belong_to(:likable).dependent(false).counter_cache }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:liker).with_message("must exist") }
    it { is_expected.to validate_presence_of(:likable).with_message("must exist") }

    context "custom validations" do
      after { like.valid? }
      it { is_expected.to receive(:like_must_be_unique_for_user_and_content) }
    end
  end

  describe "#like_must_be_unique_for_user_and_content" do
    let(:liker)   { like.liker }
    let(:likable) { like.likable }
    after { like.send(:like_must_be_unique_for_user_and_content) }

    it "checks whether a like with same liker and likable exists" do
      expect(Like).to receive(:exists?).with({
        likable_id: like.likable_id,
        likable_type: like.likable_type,
        liker: liker
      })
    end

    context "when like with user and content exists" do
      before { allow(Like).to receive(:exists?) { true } }

      it "adds an error message" do
        expect(like.errors[:base]).to receive(:<<).
          with("You have already liked this #{like.likable_type.downcase}")
      end

    end

    context "when like with user and content does not exist" do
      before { allow(Like).to receive(:exists?) { false } }

      it "does not add an error message" do
        expect(like.errors[:base]).not_to receive(:<<)
      end

    end
  end

  describe "#create_notification" do
    let(:like_notification) do
      Notification.find_by(
        :notifier => like.likable,
        :action_on_notifier => "like"
      )
    end

    it "adds a notification action" do
      like.save
      expect(Notification::Action).
        to exist(
          notification: like_notification,
          actor: like.liker,
          created_at: like.created_at)
    end

    context "when notification for likable does not exist" do
      before { Notification::Subscription.destroy_all }

      it "creates the notifaction" do
        like.save
        expect(like_notification).to be_present
      end

      it "subscribes the notifier's author to the notification" do
        like.save
        expect(Notification::Subscription).
          to exist(
            notification: like_notification,
            subscriber: like.likable.author,
            created_at: like.created_at
          )
      end
    end

    context "when liker is subscribed to the notification" do
      let(:like_notification) {
        Notification.find_by(
          :notifier => like.likable,
          :action_on_notifier => "like"
        )
      }
      let(:subscription_of_liker) {
        Notification::Subscription.find_by(
          :notification => like_notification,
          :subscriber => like.likable.author
        )
      }
      before do
        create(:like, :likable => like.likable)
        like.liker = like.likable.author
        like.save
      end

      it "updates seen_at" do
        expect(subscription_of_liker.seen_at.exact).to eq like.created_at.exact
      end
    end
  end

  describe "#destroy_notification" do
    let(:like_notification) do
      Notification.find_by(
        :notifier => like.likable,
        :action_on_notifier => "like"
      )
    end

    context "when other likes exist" do
      before do
        like.save
        create(:like, :likable => like.likable)
      end

      it "re-initalizes actions on the notification" do
        allow(Notification).to receive(:find_by).and_return(like_notification)
        expect(like_notification).to receive(:reinitialize_actions)
        like.destroy
      end
    end

    context "when other likes do not exist" do
      before do
        Like.destroy_all
        like.save
      end

      it "destroys the like notification" do
        like.destroy
        expect(like_notification).not_to be_present
      end
    end
  end

end
