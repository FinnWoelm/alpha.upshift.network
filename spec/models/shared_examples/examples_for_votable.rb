RSpec.shared_examples "a votable object" do

  describe "associations" do
    it { is_expected.to have_many(:votes).dependent(:destroy) }
    it { is_expected.to have_many(:voters).dependent(false).
      through(:votes).source(:voter) }
  end

  describe "accessors" do
    # serialize is currently not working with Rails 5.
    # See: https://github.com/thoughtbot/shoulda-matchers/issues/913
    # it {
    #   is_expected.to serialize(:votes_count)
    # }
  end

  describe "#votable_by?" do

    context "when user is nil" do
      let(:user) { nil }

      it "returns false" do
        is_expected.not_to be_votable_by(user)
      end
    end

    context "when content is already voted by user" do
      let(:user) { build_stubbed(:user) }
      before { allow(subject).to receive(:voted_by?) { true } }

      it "returns false" do
        is_expected.not_to be_votable_by(user)
      end
    end

    context "when content is not already voted by user" do
      let(:user) { build_stubbed(:user) }
      before { allow(subject).to receive(:voted_by?) { false } }

      it "returns true" do
        is_expected.to be_votable_by(user)
      end
    end

  end

  describe "#unvotable_by?" do

    context "when user is nil" do
      let(:user) { nil }

      it "returns false" do
        is_expected.not_to be_unvotable_by(user)
      end
    end

    context "when content is already voted by user" do
      let(:user) { build_stubbed(:user) }
      before { allow(subject).to receive(:voted_by?) { true } }

      it "returns true" do
        is_expected.to be_unvotable_by(user)
      end
    end

    context "when content is not already voted by user" do
      let(:user) { build_stubbed(:user) }
      before { allow(subject).to receive(:voted_by?) { false } }

      it "returns false" do
        is_expected.not_to be_unvotable_by(user)
      end
    end

  end

  describe "#voted_by?" do

    context "when content is voted by user" do
      let(:user) { build_stubbed(:user) }
      before { subject.voters << user }

      it "returns true" do
        is_expected.to be_voted_by(user)
      end
    end

    context "when content is not voted by user" do
      let(:user) { build_stubbed(:user) }
      before { subject.votes.destroy }

      it "returns false" do
        is_expected.not_to be_voted_by(user)
      end
    end

  end

  describe "#increase_votes_count" do
    let(:vote) { build_stubbed(:vote, :vote => "upvote").vote }
    before { votable.save }

    it "increases count of total votes" do
      expect{ votable.increase_votes_count(vote) }.
        to change{ votable.votes_count[:total] }.by(1)
    end

    it "increases count of upvotes" do
      expect{ votable.increase_votes_count(vote) }.
        to change{ votable.votes_count[:upvotes] }.by(1)
    end
  end

  describe "#decrease_votes_count" do
    let(:vote) { build_stubbed(:vote, :vote => "downvote").vote }
    before { votable.save }

    it "decreases count of total votes" do
      expect{ votable.decrease_votes_count(vote) }.
        to change{ votable.votes_count[:total] }.by(-1)
    end

    it "decreases count of downvotes" do
      expect{ votable.decrease_votes_count(vote) }.
        to change{ votable.votes_count[:downvotes] }.by(-1)
    end
  end

  describe "#modify_votes_count" do
    let(:new_vote) { build_stubbed(:vote, :vote => "downvote").vote }
    let(:old_vote) { build_stubbed(:vote, :vote => "upvote").vote }
    before { votable.save }

    it "decreases count of upvotes" do
      expect{ votable.modify_votes_count(new_vote, old_vote) }.
        to change{ votable.votes_count[:upvotes] }.by(-1)
    end

    it "increases count of downvotes" do
      expect{ votable.modify_votes_count(new_vote, old_vote) }.
        to change{ votable.votes_count[:downvotes] }.by(1)
    end
  end

end
