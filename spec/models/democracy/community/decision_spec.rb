require 'rails_helper'
require 'models/shared_examples/examples_for_commentable.rb'

RSpec.describe Democracy::Community::Decision, type: :model do

  subject(:decision) { build_stubbed(:democracy_community_decision) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  it_behaves_like "a commentable object" do
    subject(:commentable) { decision }
  end

  describe "associations" do
    it { is_expected.to belong_to(:community).dependent(false).class_name('Democracy::Community') }
    it { is_expected.to belong_to(:author).dependent(false).class_name('User') }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:community) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:ends_at) }
  end

  describe "#readable_by?" do
    let(:user) { nil }

    it "returns true" do
      expect(decision).to be_readable_by user
    end

  end

end
