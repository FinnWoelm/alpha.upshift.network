require 'rails_helper'

RSpec.describe Like, type: :model do

  subject(:like) { build(:like) }

  it "has a valid factory" do
    is_expected.to be_valid
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

end
