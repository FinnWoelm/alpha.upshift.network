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
    it { is_expected.to belong_to(:recipient).dependent(false) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe "scopes" do

    describe ":from_and_to_network_of_user" do
      let!(:user) { create(:user) }
      let(:network_of_user) do
        3.times do
          new_user = create(:user)
          User.all.find_each do |user|
            create(:friendship, :initiator => user, :acceptor => new_user)
          end
        end
        user.friends
      end
      let(:posts) { [] }

      it "returns posts made and received within user's network" do
        3.times do
          posts <<
            create(
              :post,
              :author => network_of_user.sample,
              :recipient => network_of_user.sample
            )
        end
        expect(Post.from_and_to_network_of_user(user)).
          to include *posts
      end

      it "does not return posts made outside user's network" do
        3.times do
          posts <<
            create(
              :post,
              :recipient => network_of_user.sample
            )
        end
        expect(Post.from_and_to_network_of_user(user)).
          not_to include *posts
      end

      it "does not return posts received outside user's network" do
        3.times do
          posts <<
            create(
              :post,
              :author => network_of_user.sample
            )
        end
        expect(Post.from_and_to_network_of_user(user)).
          not_to include *posts
      end

      it "returns posts made to user" do
        3.times do
          posts <<
            create(
              :post,
              :author => user
            )
        end
        expect(Post.from_and_to_network_of_user(user)).
          to include *posts
      end

      it "returns post made by user" do
        3.times do
          posts <<
            create(
              :post,
              :recipient => user
            )
        end
        expect(Post.from_and_to_network_of_user(user)).
          to include *posts
      end
    end

    describe ":most_recent_first" do
      after { Post.most_recent_first }

      it "orders post by their creation date in descending order" do
        expect(Post).to receive(:order).with('posts.created_at DESC')
      end

    end

    describe ":posts_made_and_received" do
      let(:user) { create(:user) }
      let(:posts_made) { create_list(:post, 3, :author => user) }
      let(:posts_received) { create_list(:post, 3, :recipient => user) }
      let(:unrelated_posts) { create_list(:post, 3) }

      it "returns posts made by user" do
        expect(Post.made_and_received_by_user(user)).
          to include *posts_made
      end

      it "returns posts posted to user" do
        expect(Post.made_and_received_by_user(user)).
          to include *posts_received
      end

      it "does not return posts unrelated to user" do
        expect(Post.made_and_received_by_user(user)).
          not_to include *unrelated_posts
      end
    end

    describe ":readable_by_user" do
      let(:user) { create(:user) }

      after { Post.readable_by_user(user) }

      it "merges User.viewable_by_user for authors and for recipients" do
        expect(User).
          to receive(:viewable_by_user).with(user, "authors").and_call_original
        expect(User).
          to receive(:viewable_by_user).with(user, "recipients").and_call_original
      end

      context "when user is author" do
        let!(:post) { create(:post, :recipient => create(:user)) }
        before do
          post.author.private_visibility!
          post.recipient.private_visibility!
        end

        it "returns true" do
          expect(Post.readable_by_user(post.author)).to include(post)
        end
      end

      context "when user is profile owner" do
        let!(:post) { create(:post, :recipient => create(:user)) }
        before do
          post.author.private_visibility!
          post.recipient.private_visibility!
        end

        it "returns true" do
          expect(Post.readable_by_user(post.recipient)).to include(post)
        end
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
    it { is_expected.to validate_presence_of(:author).with_message("must exist") }
    it { is_expected.to validate_presence_of(:recipient).with_message("must exist") }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(5000) }
    it { is_expected.to validate_length_of(:content).is_at_most(5000) }

    context "custom validations" do
      after { post.valid? }
      it { is_expected.to receive(:author_can_post_to_recipient) }
    end
  end

  describe "#readable_by?" do
    let(:post) { create(:post) }
    let(:user) { nil }

    context "when user cannot view author" do
      before do
        allow(post).to receive_message_chain(:author, :viewable_by?) {false}
        allow(post).to receive_message_chain(:recipient, :viewable_by?) {true}
      end

      it "returns false" do
        is_expected.not_to be_readable_by(user)
      end
    end

    context "when user cannot view recipient" do
      before do
        allow(post.author).to receive(:viewable_by?) {true}
        allow(post.recipient).to receive(:viewable_by?) {false}
      end

      it "returns false" do
        is_expected.not_to be_readable_by(user)
      end
    end

    context "when user can view author and recipient" do
      before do
        allow(post.author).to receive(:viewable_by?) {true}
        allow(post.recipient).to receive(:viewable_by?) {true}
      end

      it "returns true" do
        is_expected.to be_readable_by(user)
      end
    end

    context "when user is author" do
      let(:user) { post.author }

      before do
        allow(post.author).to receive(:viewable_by?) {true}
        allow(post.recipient).to receive(:viewable_by?) {false}
      end

      it "returns true" do
        expect(post).to be_readable_by(user)
      end
    end

    context "when user is recipient" do
      let(:user) { post.recipient }

      before do
        allow(post.author).to receive(:viewable_by?) {false}
        allow(post.recipient).to receive(:viewable_by?) {true}
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

  describe "#author_can_post_to_recipient" do
    after { post.send(:author_can_post_to_recipient) }
    let(:recipient) { post.recipient }

    context "when author can view recipient" do
      before { allow(recipient).to receive(:viewable_by?) {true} }

      it "does not add an error message" do
        expect(post.errors[:recipient]).not_to receive(:<<)
      end
    end

    context "when author cannot view recipient" do
      before { allow(recipient).to receive(:viewable_by?) {false} }

      it "adds an error message" do
        expect(post.errors[:recipient]).to receive(:<<).
          with("does not exist or is private")
      end
    end

  end
end
