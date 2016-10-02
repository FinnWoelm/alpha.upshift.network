require 'rails_helper'
include SignInHelper

RSpec.describe "profiles/show", type: :view do
  before(:each) do
    @profile = create(:user).profile
    @current_user = create(:user)
    @posts = []
  end

  it "renders user's name" do
    render
    expect(rendered).to have_text(@profile.user.name)
  end

  it "renders most recent posts first" do
    @posts_to_check = []
    5.times { @posts_to_check << create(:post, :author => @current_user) }

    @posts = @current_user.posts.most_recent_first.with_associations

    render

    expect(@posts_to_check[4].content).to appear_before(@posts_to_check[3].content)
    expect(@posts_to_check[3].content).to appear_before(@posts_to_check[2].content)
    expect(@posts_to_check[2].content).to appear_before(@posts_to_check[1].content)
    expect(@posts_to_check[1].content).to appear_before(@posts_to_check[0].content)
  end

  context "No friendship request has been sent" do
    it "has an add friend button" do
      render
      expect(rendered).to have_selector("button", text: "Send Friend Request", count: 1)
    end
  end

  context "Friendship request has been sent by user viewing profile" do
    it "has a revoke friend request button" do
      create(:friendship_request, :recipient => @profile.user, :sender => @current_user)
      render
      expect(rendered).to have_selector("a", text: "Revoke Request", count: 1)
    end
  end

  context "Friendship request has been sent to user viewing profile" do

    before(:each) do
      create(:friendship_request, :sender => @profile.user, :recipient => @current_user)
    end

    it "has an accept friend request button" do
      render
      expect(rendered).to have_selector("button", text: "Accept", count: 1)
    end
    it "has a reject friend request button" do
      render
      expect(rendered).to have_selector("a", text: "Reject", count: 1)
    end
  end

  context "Friendship exists between users" do
    it "has an unfriend button" do
      create(:friendship, :initiator => @profile.user, :acceptor => @current_user)
      render
      expect(rendered).to have_selector("a", text: "Unfriend", count: 1)      
    end
  end

end
