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

  describe "accessors" do
    it {
      is_expected.to define_enum_for(:action_on_notifier).
        with([:post, :comment, :like])
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

  end
end
