require 'rails_helper'

RSpec.describe Vote, type: :model do

  subject(:vote) { build(:vote) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:voter).dependent(false).class_name('User') }
    it { is_expected.to belong_to(:votable).dependent(false).counter_cache }
  end

  describe "accessors" do
    it {
      is_expected.to define_enum_for(:vote).
        with([:upvote, :downvote])
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:voter) }
    it { is_expected.to validate_presence_of(:votable_id) }
    it { is_expected.to validate_presence_of(:votable_type) }
    it { is_expected.to validate_inclusion_of(:votable_type).
          in_array(["Democracy::Community::Decision"]) }

    context "custom validations" do
      after { vote.valid? }
      it { is_expected.to receive(:vote_must_be_unique_for_user_and_content) }
    end
  end

  describe "#vote_must_be_unique_for_user_and_content" do
    let(:voter)   { vote.voter }
    let(:votable) { vote.votable }
    after { vote.send(:vote_must_be_unique_for_user_and_content) }

    it "checks whether a vote with same voter and votable exists" do
      expect(Vote).to receive(:exists?).with({
        votable_id: vote.votable_id,
        votable_type: vote.votable_type,
        voter: voter
      })
    end

    context "when vote with user and content exists" do
      before { allow(Vote).to receive(:exists?) { true } }

      it "adds an error message" do
        expect(vote.errors[:base]).to receive(:<<).
          with("You have already voted on this #{vote.votable_type.downcase}")
      end

    end

    context "when vote with user and content does not exist" do
      before { allow(Vote).to receive(:exists?) { false } }

      it "does not add an error message" do
        expect(vote.errors[:base]).not_to receive(:<<)
      end

    end
  end

end
