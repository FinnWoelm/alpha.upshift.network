require 'rails_helper'
include SignInHelper

RSpec.describe "Friendship", type: :request do
  describe "POST friendship/:username" do

    before(:each) do
      @friendship_request = create(:friendship_request)
      sign_in_as(@friendship_request.recipient)
    end

    it "destroys the request when it is created" do
      post accept_friendship_request_path(@friendship_request.sender)
      assert_redirected_to @friendship_request.sender
      expect{@friendship_request.reload}.to raise_error(ActiveRecord::RecordNotFound)
      expect(Friendship.all.size).to eq(1)
    end

  end

  describe "DELETE friendship/:username" do

    before(:each) do
      @friendship = create(:friendship)
      sign_in_as(@friendship.acceptor)
    end

    it "destroys the friendship" do
      delete end_friendship_path(@friendship.initiator)
      assert_redirected_to @friendship.initiator
      expect(@friendship.acceptor).not_to have_friendship_with (@friendship.initiator)
    end

  end

end
