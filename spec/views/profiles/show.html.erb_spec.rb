require 'rails_helper'
include SignInHelper

RSpec.describe "profiles/show", type: :view do
  before(:each) do
    @profile = create(:user).profile
    @current_user = create(:user)
    @posts = []
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Username/)
    expect(rendered).to match(@profile.user.name)
  end

  context "No friendship request has been sent" do
    it "has an add friend button" do
      render
      assert_select "input[type=submit][value='Add Friend']", :count => 1
    end
  end

  context "Friendship request has been sent by user viewing profile" do
    it "has a revoke friend request button" do
      create(:friendship_request, :recipient => @profile.user, :sender => @current_user)
      render
      assert_select "a", :text => "Revoke request", :count => 1
    end
  end

  context "Friendship request has been sent to user viewing profile" do

    before(:each) do
      create(:friendship_request, :sender => @profile.user, :recipient => @current_user)
    end

    it "has an accept friend request button" do
      render
      assert_select "input[type=submit][value='Accept']", :count => 1
    end
    it "has a reject friend request button" do
      render
      assert_select "a", :text => "Reject", :count => 1
    end
  end

  context "Friendship exists between users" do
    it "has an unfriend button" do
      create(:friendship, :initiator => @profile.user, :acceptor => @current_user)
      render
      assert_select "a", :text => "Unfriend", :count => 1
    end
  end

end
