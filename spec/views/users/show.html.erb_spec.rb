require 'rails_helper'
include SignInHelper

RSpec.describe "users/show", type: :view do

  let(:current_user) { create(:user) }
  let(:user) { create(:user) }

  before do
    assign(:current_user, current_user)
    assign(:user, user)
    assign(:post, build(:post, :recipient => user))
    assign(:posts, Post.paginate(:page => 1))
  end

  it "renders user's name" do
    render
    expect(rendered).to have_text(user.name)
  end

  it "renders most recent posts first" do
    posts_to_check = []
    5.times { posts_to_check << create(:post, :author => current_user) }

    assign(:posts, current_user.posts_made_and_received.most_recent_first.with_associations)
    allow_any_instance_of(ApplicationHelper).to receive(:infinity_scroll_fallback).and_return(nil)
    allow_any_instance_of(ApplicationHelper).to receive(:infinity_scroll).and_return(nil)

    render

    expect(posts_to_check[4].content).to appear_before(posts_to_check[3].content)
    expect(posts_to_check[3].content).to appear_before(posts_to_check[2].content)
    expect(posts_to_check[2].content).to appear_before(posts_to_check[1].content)
    expect(posts_to_check[1].content).to appear_before(posts_to_check[0].content)
  end

  it "shows a button for starting a private conversation" do
    render
    expect(rendered).to have_selector("button", text: "Message")
  end

  context "No friendship request has been sent" do
    it "has an add friend button" do
      render
      expect(rendered).to have_selector("button", text: "Add Friend", count: 1)
    end
  end

  context "Friendship request has been sent by user viewing profile" do
    it "has a revoke friend request button" do
      create(:friendship_request, :recipient => user, :sender => current_user)
      render
      expect(rendered).to have_selector("button", text: "Cancel Friend Request", count: 1)
    end
  end

  context "Friendship request has been sent to user viewing profile" do

    before(:each) do
      create(:friendship_request, :sender => user, :recipient => current_user)
    end

    it "has an accept friend request button" do
      render
      expect(rendered).to have_selector("button", text: "Accept Friend Request", count: 1)
    end
    it "has a reject friend request button" do
      render
      expect(rendered).to have_selector("button", text: "Reject Friend Request", count: 1)
    end
  end

  context "Friendship exists between users" do
    it "has an unfriend button" do
      create(:friendship, :initiator => user, :acceptor => current_user)
      render
      expect(rendered).to have_selector("button", text: "End Friendship", count: 1)
    end
  end

end
