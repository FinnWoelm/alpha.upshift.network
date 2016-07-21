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
      expect(@profile.can_be_seen_by?(@user)).to be true
    end

    it "can be seen by a network user" do
      @user = create(:user)
      expect(@profile.can_be_seen_by?(@user)).to be true
    end

    it "can be seen by a friend" do
      @user = create(:friendship, :initiator => @profile.user).acceptor
      expect(@profile.can_be_seen_by?(@user)).to be true
    end

  end

  context "profile is network-only, therefore it" do

    before(:each) do
      @profile = create(:profile, :visibility => "is_network_only")
    end

    it "cannot be seen by a public user" do
      @user = nil
      expect(@profile.can_be_seen_by?(@user)).to be false
    end

    it "can be seen by a network user" do
      @user = create(:user)
      expect(@profile.can_be_seen_by?(@user)).to be true
    end

    it "can be seen by a friend" do
      @user = create(:friendship, :initiator => @profile.user).acceptor
      expect(@profile.can_be_seen_by?(@user)).to be true
    end

  end

  context "profile is friends-only (private), therefore it" do

    before(:each) do
      @profile = create(:profile, :visibility => "is_private")
    end

    it "cannot be seen by a public user" do
      @user = nil
      expect(@profile.can_be_seen_by?(@user)).to be false
    end

    it "cannot be seen by a network user" do
      @user = create(:user)
      expect(@profile.can_be_seen_by?(@user)).to be false
    end

    it "can be seen by a friend" do
      @user = create(:friendship, :initiator => @profile.user).acceptor
      expect(@profile.can_be_seen_by?(@user)).to be true
    end

  end

end
