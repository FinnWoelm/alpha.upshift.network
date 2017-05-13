require 'rails_helper'

RSpec.describe NotificationsHelper, type: :helper do

  describe "#notification_title" do
    subject {
      helper.notification_title actors, other_actors, action, notifier, subscription_reason
    }
    let(:action) { "post" }
    let(:notifier) { build(:post) }
    let(:subscription_reason) { "recipient" }
    let(:actors) { build_list(:user, 1, :name => "Ben") }
    let(:other_actors) { false }

    describe "with one actor" do
      let(:actors) do
         [build(:user, :name => "Ben")]
      end
      it { is_expected.to match "Ben" }
    end

    describe "with two actors" do
      let(:actors) do
         [build(:user, :name => "Ben"),
         build(:user, :name => "Alice")]
      end
      it { is_expected.to match "Ben and Alice" }
    end

    describe "with three actors" do
      let(:actors) do
         [build(:user, :name => "Ben"),
         build(:user, :name => "Alice"),
         build(:user, :name => "Jerry")]
      end
      it { is_expected.to match "Ben, Alice, and Jerry" }
    end

    describe "with three actors and others" do
      let(:actors) do
         [build(:user, :name => "Ben"),
         build(:user, :name => "Alice"),
         build(:user, :name => "Jerry")]
      end
      let(:other_actors) { true }
      it { is_expected.to match "Ben, Alice, Jerry, and others" }
    end

    describe "when a user posts on your profile" do
      let(:action) { "post" }
      let(:notifier) { build(:post) }
      let(:subscription_reason) { "recipient" }
      it { is_expected.to match "Ben posted on your profile" }
    end

    describe "when a user comments on a post you wrote" do
      let(:action) { "comment" }
      let(:notifier) { build(:post) }
      let(:subscription_reason) { "author" }
      it { is_expected.to match "Ben commented on your post" }
    end

    describe "when a user comments on a post you received" do
      let(:action) { "comment" }
      let(:notifier) { build(:post) }
      let(:subscription_reason) { "recipient" }
      it { is_expected.to match "Ben commented on a post on your profile" }
    end

    describe "when a user comments on a post you commented on" do
      let(:action) { "comment" }
      let(:notifier) { build(:post) }
      let(:subscription_reason) { "commenter" }
      it { is_expected.to match "Ben also commented on a post" }
    end

    describe "when a user likes a post you wrote" do
      let(:action) { "like" }
      let(:notifier) { build(:post) }
      let(:subscription_reason) { "author" }
      it { is_expected.to match "Ben liked your post" }
    end

    describe "when a user likes a comment you wrote" do
      let(:action) { "like" }
      let(:notifier) { build(:comment) }
      let(:subscription_reason) { "author" }
      it { is_expected.to match "Ben liked your comment" }
    end

    describe "when a user likes a post you received" do
      let(:action) { "like" }
      let(:notifier) { build(:post) }
      let(:subscription_reason) { "recipient" }
      it { is_expected.to match "Ben liked a post on your profile" }
    end
  end
end
