require 'rails_helper'
require 'models/shared_examples/examples_for_likable.rb'
require 'models/shared_examples/examples_for_commentable.rb'

RSpec.describe Post, type: :model do

  subject(:post) { build_stubbed(:post) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  it_behaves_like "a likable object" do
    subject(:likable) { post }
  end

  it_behaves_like "a commentable object" do
    subject(:commentable) { post }
  end

  describe "associations" do
    it { is_expected.to belong_to(:author).dependent(false).class_name('User') }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe "scopes" do

    describe ":most_recent_first" do
      after { Post.most_recent_first }

      it "orders post by their creation date in descending order" do
        expect(Post).to receive(:order).with('posts.created_at DESC')
      end

    end

    describe ":with_associations" do
      before { create(:post) }
      let(:post) { Post.with_associations.first }

      it "eagerloads comments" do
        expect(post.association(:comments)).to be_loaded
      end

      it "eagerloads author" do
        expect(post.association(:author)).to be_loaded
      end

      it "eagerloads likes" do
        expect(post.association(:likes)).to be_loaded
      end

    end

  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(5000) }
  end

  describe "#readable_by?" do
    let(:user) { build_stubbed(:user) }

    context "when calling the function" do
      let(:author_of_post) { instance_double(User) }
      after { post.send(:readable_by?, user) }

      it "checks whether author's profile is viewable by user" do
        expect(post).to receive(:author) { author_of_post }
        expect(author_of_post).to receive(:viewable_by?).with(user)
      end
    end

    context "when user cannot view profile" do
      before do
        allow(post).
          to receive_message_chain(:author, :viewable_by?) {false}
      end

      it "returns false" do
        is_expected.not_to be_readable_by(user)
      end
    end

    context "when user can view profile" do
      before do
        allow(post).
          to receive_message_chain(:author, :viewable_by?) {true}
      end

      it "returns true" do
        is_expected.to be_readable_by(user)
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

    context "when user is not author of post" do
      let(:user) { object_double(post.author, :id => post.author.id + 1) }

      it "returns false" do
        is_expected.not_to be_deletable_by(user)
      end
    end

    context "when user is author of post" do
      let(:user) { post.author }

      it "returns true" do
        is_expected.to be_deletable_by(user)
      end
    end

  end
end
