require 'rails_helper'

RSpec.describe Notification, type: :model do

  subject(:notification) { build(:notification) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:notifier).dependent(false) }
    it { is_expected.to have_many(:actions).
      class_name("Notification::Action").dependent(:delete_all) }
    it { is_expected.to have_many(:actors).dependent(false).
      through(:actions).source(:actor) }
    it { is_expected.to have_many(:subscriptions).
      class_name("Notification::Subscription").dependent(:delete_all) }
    it { is_expected.to have_many(:subscribers).dependent(false).
      through(:subscriptions).source(:subscriber) }
  end

  describe "scopes" do

    describe ":for_user" do
      let(:user) { create(:user) }
      let!(:post) { create(:post, :recipient => user) }
      let!(:comment) { create(:comment, :commentable => post) }
      let!(:like) { create(:like, :likable => post) }
      let(:notifications) { Notification.for_user(user) }

      it "returns 3 notifications the user is subscribed to" do
        expect(notifications.count).to eq 3
        expect(notifications.map(&:notifier)).to match [post, post, post]
        expect(notifications.map(&:action_on_notifier)).to match_array ["post", "comment", "like"]
      end

      it "sorts notifications in order of last action" do
        expect(notifications.first.actions.first.created_at).to be > notifications.second.actions.first.created_at
        expect(notifications.second.actions.first.created_at).to be > notifications.third.actions.first.created_at
      end

      it "returns all actions that occured after the user subscribed" do
        comment_notification = Notification.find_by(:notifier => post, :action_on_notifier => "comment")
        comment_notification.subscriptions.
          find_by(:subscriber => user).update(:created_at => Time.now)
        create(:comment, :commentable => post)
        expect(notifications.includes(:actions).first.actions.size).to eq 1
      end

      it "returns only the user's subscription" do
        expect(notifications.includes(:subscriptions).first.subscriptions.size).to eq 1
        expect(notifications.includes(:subscriptions).first.subscriptions.first.subscriber_id).to eq user.id
      end

      describe "when the notification has no actions" do
        it "does not return the notification" do
          expect {
            Notification.where(:notifier => post).first.actions.delete_all
          }.to change {
            notifications.count
          }.by(-1)
        end
      end

      describe "when actor of last action is user" do
        it "does not return the notification" do
          expect {
            Notification::Action.
            where(:actor => comment.author).update(:actor => user)
          }.to change {
            notifications.count
          }.by(-1)
        end
      end

      describe "when last action created_at < subscription.created_at" do
        it "does not return the notification" do
          expect {
            Notification::Subscription.
            where(:subscriber => user).first.update(:created_at => Time.now)
          }.to change {
            notifications.count
          }.by(-1)
        end
      end

      describe ":unseen_only" do
        let(:user) { create(:user) }
        let!(:post) { create(:post, :recipient => user) }
        let!(:comment) { create(:comment, :commentable => post) }
        let!(:like) { create(:like, :likable => post) }
        let(:notifications) { Notification.for_user(user).unseen_only }

        it "returns notifications where last_action.created_at > subscription.seen_at" do
          expect {
            Notification::Subscription.
            where(:subscriber => user).first.touch(:seen_at)
          }.to change {
            notifications.count
          }.by(-1)
        end

        it "returns notifications where subscription.seen_at is nil" do
          Notification::Subscription.
            where(:subscriber => user).update_all(:seen_at => Time.zone.now)
          expect {
            Notification::Subscription.
            where(:subscriber => user).first.update(:seen_at => nil)
          }.to change {
            notifications.count
          }.by(1)
        end
      end
    end
  end

  describe "accessors" do
    it {
      is_expected.to define_enum_for(:action_on_notifier).
        with([:post, :comment, :like, :friendship_request])
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:notifier).with_message("must exist") }
  end

  describe "#reinitalize_actions" do
    let!(:post) { create(:post) }
    let(:notification) do
      Notification.find_by(
        :notifier => post,
        :action_on_notifier => :comment
      )
    end
    before do
      create_list(:comment, 5, :commentable => post)
    end

    it "recreates last three actions" do
      notification.reinitialize_actions
      actions =
        notification.actions.reload
      expect(actions[0].actor).to eq notification.notifier.comments[-1].author
      expect(actions[1].actor).to eq notification.notifier.comments[-2].author
      expect(actions[2].actor).to eq notification.notifier.comments[-3].author
    end

    it "sets others_acted_before" do
      notification.reinitialize_actions
      expect(notification.others_acted_before).
        to eq notification.notifier.comments[-4].created_at
    end

    it "only gets unique actors" do
      Comment.find_each do |comment|
        comment.update(:author => post.author)
      end

      notification.reinitialize_actions

      expect(notification.actors.count).to eq 1
      expect(notification.others_acted_before).to eq nil
    end

    context "when action on notifier is post" do
      let(:post) { create(:post) }
      let!(:notification) { Notification.find_by(notifier: post, action_on_notifier: :post) }
      let!(:actions) { notification.actions.map { |a| [a.actor_id, a.created_at] } }
      let!(:others_acted_before) { notification.others_acted_before }

      it "successfully reinitializes actions" do
        successfully_reinitializes_actions
      end
    end

    context "when action on notifier is comment" do
      let(:post) { create(:post) }
      let!(:comments) { create_list(:comment, 3, :commentable => post)}
      let!(:notification) { Notification.find_by(notifier: post, action_on_notifier: :comment) }
      let!(:actions) { notification.actions.map { |a| [a.actor_id, a.created_at] } }
      let!(:others_acted_before) { notification.others_acted_before }

      it "successfully reinitializes actions" do
        successfully_reinitializes_actions
      end
    end

    context "when action on notifier is like" do
      let(:post) { create(:post) }
      let!(:likes) { create_list(:like, 4, :likable => post)}
      let!(:notification) { Notification.find_by(notifier: post, action_on_notifier: :like) }
      let!(:actions) { notification.actions.map { |a| [a.actor_id, a.created_at] } }
      let!(:others_acted_before) { notification.others_acted_before }

      it "successfully reinitializes actions" do
        successfully_reinitializes_actions
      end
    end

    context "when action on notifier is friend request" do
      let(:user) { create(:user) }
      let!(:friendship_requests) { create_list(:friendship_request, 4, :recipient => user)}
      let!(:notification) { Notification.find_by(notifier: user, action_on_notifier: :friendship_request) }
      let!(:actions) { notification.actions.map { |a| [a.actor_id, a.created_at] } }
      let!(:others_acted_before) { notification.others_acted_before }

      it "successfully reinitializes actions" do
        successfully_reinitializes_actions
      end
    end

    def successfully_reinitializes_actions
      notification.actions.clear
      notification.reinitialize_actions
      notification.actions.reload
      # match size
      expect(notification.actions.size).to eq actions.size
      # match others_acted_before
      expect(notification.others_acted_before).to eq others_acted_before
      # match each action
      expect(
        notification.actions.map {|action| [action.actor_id, action.created_at] }
      ).to eq(
        actions
      )
    end
  end
end
