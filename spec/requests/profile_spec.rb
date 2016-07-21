require 'rails_helper'
include SignInHelper

RSpec.describe "Profile", type: :request do
  describe "GET /:username" do

    before(:each) do
      @user = create(:user)
    end

    it "throws error if username does not exist" do
      another_user = build(:user) # build but not create
      get profile_path(another_user.username)
      assert_response :not_found
    end

  end
end
