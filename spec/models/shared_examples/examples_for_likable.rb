RSpec.shared_examples "a likable object" do

  describe "associations" do
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:likers).dependent(false).
      through(:likes).source(:liker) }
  end

  describe "#likable_by?" do

    context "when user is nil" do
      let(:user) { nil }

      it "returns false" do
        is_expected.not_to be_likable_by(user)
      end
    end

    context "when content is already liked by user" do
      let(:user) { build_stubbed(:user) }
      before { allow(subject).to receive(:liked_by?) { true } }

      it "returns false" do
        is_expected.not_to be_likable_by(user)
      end
    end

    context "when content is not already liked by user" do
      let(:user) { build_stubbed(:user) }
      before { allow(subject).to receive(:liked_by?) { false } }

      it "returns true" do
        is_expected.to be_likable_by(user)
      end
    end

  end

  describe "#unlikable_by?" do

    context "when user is nil" do
      let(:user) { nil }

      it "returns false" do
        is_expected.not_to be_unlikable_by(user)
      end
    end

    context "when content is already liked by user" do
      let(:user) { build_stubbed(:user) }
      before { allow(subject).to receive(:liked_by?) { true } }

      it "returns true" do
        is_expected.to be_unlikable_by(user)
      end
    end

    context "when content is not already liked by user" do
      let(:user) { build_stubbed(:user) }
      before { allow(subject).to receive(:liked_by?) { false } }

      it "returns false" do
        is_expected.not_to be_unlikable_by(user)
      end
    end

  end

  describe "#liked_by?" do

    context "when content is liked by user" do
      let(:user) { build_stubbed(:user) }
      before { subject.likers << user }

      it "returns true" do
        is_expected.to be_liked_by(user)
      end
    end

    context "when content is not liked by user" do
      let(:user) { build_stubbed(:user) }
      before { subject.likes.destroy }

      it "returns false" do
        is_expected.not_to be_liked_by(user)
      end
    end

  end

end
