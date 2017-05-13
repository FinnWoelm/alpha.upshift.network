require 'rails_helper'
require 'models/shared_examples/examples_for_likable.rb'
require 'models/shared_examples/examples_for_notifying.rb'

RSpec.describe Comment, type: :model do

  subject(:comment) { build(:comment) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  it_behaves_like "a likable object" do
    subject(:likable) { comment }
  end

  it_behaves_like "a notifying object" do
    subject(:notifier) { build(:comment) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:author).dependent(false).class_name('User') }
    it { is_expected.to belong_to(:commentable).dependent(false) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:author).with_message("must exist") }
    it { is_expected.to validate_presence_of(:commentable).with_message("must exist") }

    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(1000) }

    it "validates that #author_must_be_able_to_see_post" do
      expect(comment).to receive(:author_must_be_able_to_see_commentable)
      comment.valid?
    end
  end

  describe "#create_notification" do
    let(:comment_notification) do
      Notification.find_by(
        :notifier => comment.commentable,
        :action_on_notifier => "comment"
      )
    end
    let(:commenter_subscription) do
      Notification::Subscription.find_by(
        :notification => comment_notification,
        :subscriber => comment.author,
        :created_at => comment.created_at
      )
    end

    context "when comment author is already subscribed" do
      before { comment.save }

      it "updates :seen_at to comment.created_at" do
        comment.send(:create_notification)
        expect(commenter_subscription.seen_at.exact).to eq comment.created_at.exact
      end
    end

    context "when comment author is not yet subscribed" do
      before do
        comment.save
        commenter_subscription.destroy
      end

      it "subscribes the author to comments on the post" do
        comment.send(:create_notification)
        expect(commenter_subscription).to be_present
      end
    end

    it "creates an action for comment" do
      comment.save
      expect(Notification::Action).
        to exist(
          notification: comment_notification,
          actor: comment.author,
          created_at: comment.created_at)
    end
  end

  describe "#destroy_notification" do
    let!(:comment) { create(:comment) }
    let!(:comment_author) { comment.author }
    let(:comment_notification) do
      Notification.find_by(
        :notifier => comment.commentable,
        :action_on_notifier => "comment"
      )
    end
    let(:comment_author_subscription) do
      Notification::Subscription.find_by(
        :notification => comment_notification,
        :subscriber => comment_author,
        :reason_for_subscription => :commenter
      )
    end

    it "destroys any notification(s) associated with the comment" do
      comment.destroy
      expect(Notification.where(:notifier => comment).count).to eq 0
    end

    it "unsubscribes the comment author from comment notifications" do
      comment.destroy
      expect(comment_author_subscription).to be_nil
    end

    it "re-initalizes the comment notification" do
      allow(Notification).to receive(:find_by).and_return(comment_notification)
      expect(comment_notification).to receive(:reinitialize_actions)
      comment.destroy
    end

    context "when comment author has another comment" do
      before do
        create(:comment,
          commentable: comment.commentable,
          author: comment.author)
      end

      it "does not unsubscribe the comment author from comment notifications" do
        comment.destroy
        expect(comment_author_subscription).to be_present
      end
    end
  end

  describe "#deletable_by?" do

    context "when user is nil" do
      let(:user) { nil }

      it "returns false" do
        is_expected.not_to be_deletable_by(user)
      end
    end

    context "when user is not author of comment" do
      let(:user) { object_double(comment.author, :id => comment.author.id + 1) }

      it "returns false" do
        is_expected.not_to be_deletable_by(user)
      end
    end

    context "when user is author of comment" do
      let(:user) { comment.author }

      it "returns true" do
        is_expected.to be_deletable_by(user)
      end
    end
  end

  describe "#author_must_be_able_to_see_commentable" do
    let(:post) { comment.commentable }
    after { comment.send(:author_must_be_able_to_see_commentable) }

    it "checks whether the post is readable by the comment author" do
      expect(post).to receive(:readable_by?).with(comment.author)
    end

    context "when author cannot see post" do
      before { allow(post).to receive(:readable_by?) { false } }

      it "adds an error message" do
        expect(comment.errors[:base]).to receive(:<<).
          with("An error occurred. " +
          "Either the post never existed, it does not exist anymore, " +
          "or you do not have permission to view it.")
      end

    end

    context "when author can see post" do
      before { allow(post).to receive(:readable_by?) { true } }

      it "does not add an error message" do
        expect(comment.errors[:base]).not_to receive(:<<).
          with("An error occurred. " +
          "Either the post never existed, it does not exist anymore, " +
          "or you do not have permission to view it.")
      end

    end

  end

end
