require 'rails_helper'
include SignInHelper

RSpec.describe "FriendshipRequest", type: :request do
  describe "DELETE friendship-request/:username" do

    before(:each) do
      @friendship_request = create(:friendship_request)
      sign_in_as(@friendship_request.recipient)
    end

    it "destroys the request" do
      get friendship_requests_received_path
      delete reject_friendship_request_path(@friendship_request.sender)
      assert_redirected_to friendship_requests_received_path
      expect{@friendship_request.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end

  end
end
