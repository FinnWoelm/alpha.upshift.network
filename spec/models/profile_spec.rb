require 'rails_helper'

RSpec.describe Profile, type: :model do

  it {
    should define_enum_for(:visibility).
      with([:is_private, :is_network_only, :is_public])
  }

  context "profile is public, therefore it" do

    before(:each) do
      @profile = create(:profile, :visibility => "is_public")
    end

    it "can be seen by a public user" do
      @user = nil
      expect(@profile).to be_viewable_by(@user)
    end

    it "can be seen by a network user" do
      @user = create(:user)
      expect(@profile).to be_viewable_by(@user)
    end

    it "can be seen by a friend" do
      @user = create(:friendship, :initiator => @profile.user).acceptor
      expect(@profile).to be_viewable_by(@user)
    end

  end

  context "profile is network-only, therefore it" do

    before(:each) do
      @profile = create(:profile, :visibility => "is_network_only")
    end

    it "cannot be seen by a public user" do
      @user = nil
      expect(@profile).not_to be_viewable_by(@user)
    end

    it "can be seen by a network user" do
      @user = create(:user)
      expect(@profile).to be_viewable_by(@user)
    end

    it "can be seen by a friend" do
      @user = create(:friendship, :initiator => @profile.user).acceptor
      expect(@profile).to be_viewable_by(@user)
    end

  end

  context "profile is friends-only (private), therefore it" do

    before(:each) do
      @profile = create(:profile, :visibility => "is_private")
    end

    it "cannot be seen by a public user" do
      @user = nil
      expect(@profile).not_to be_viewable_by(@user)
    end

    it "cannot be seen by a network user" do
      @user = create(:user)
      expect(@profile).not_to be_viewable_by(@user)
    end

    it "can be seen by a friend" do
      @user = create(:friendship, :initiator => @profile.user).acceptor
      expect(@profile).to be_viewable_by(@user)
    end

  end

end
