require 'rails_helper'

RSpec.describe Profile, type: :model do

  subject(:profile) { build_stubbed(:profile) }

  it "has a valid factory" do
    is_expected.to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).dependent(false).inverse_of(:profile) }
  end

  describe "accessors" do
    it {
      is_expected.to define_enum_for(:visibility).
        with([:is_private, :is_network_only, :is_public])
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:user) }
  end

  describe "#viewable_by?" do
    subject(:profile) { create(:profile)}
    let(:anonymous_user) { nil }
    let(:registered_user) { build_stubbed(:user) }
    let(:friend) { create(:friendship, initiator: profile.user, acceptor: create(:user)).acceptor }
    let(:profile_owner) { profile.user }

    context "when visibility is public" do
      before { profile.is_public! }

      it "is viewable by anonymous users" do
        is_expected.to be_viewable_by anonymous_user
      end
      it "is viewable by registered users" do
        is_expected.to be_viewable_by registered_user
      end
      it "is viewable by friends" do
        is_expected.to be_viewable_by friend
      end
      it "is viewable by profile owner" do
        is_expected.to be_viewable_by profile_owner
      end
    end

    context "when visibility is network-only" do
      before { profile.is_network_only! }

      it "is not viewable by anonymous users" do
        is_expected.not_to be_viewable_by anonymous_user
      end
      it "is viewable by registered users" do
        is_expected.to be_viewable_by registered_user
      end
      it "is viewable by friends" do
        is_expected.to be_viewable_by friend
      end
      it "is viewable by profile owner" do
        is_expected.to be_viewable_by profile_owner
      end
    end

    context "when visibility is network-only" do
      before { profile.is_private! }

      it "is not viewable by anonymous users" do
        is_expected.not_to be_viewable_by anonymous_user
      end
      it "is not viewable by registered users" do
        is_expected.not_to be_viewable_by registered_user
      end
      it "is viewable by friends" do
        is_expected.to be_viewable_by friend
      end
      it "is viewable by profile owner" do
        is_expected.to be_viewable_by profile_owner
      end
    end
  end

end
