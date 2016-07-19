require 'rails_helper'
include SignInHelper

RSpec.describe "Friendship", type: :request do
  describe "POST friendship/:username" do

    before(:each) do
      @friendship_request = create(:friendship_request)
      sign_in_as(@friendship_request.recipient)
    end

    it "destroys the request when it is created" do
      post accept_friendship_request_path(@friendship_request)
      assert_response :success
      expect{@friendship_request.reload}.to raise_error(ActiveRecord::RecordNotFound)
      expect(Friendship.all.size).to eq(1)
    end

  end
end
