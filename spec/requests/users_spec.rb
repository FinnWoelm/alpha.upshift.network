require 'rails_helper'
include SignInHelper

RSpec.describe "Users", type: :request do
  describe "GET /:username" do

    before(:each) do
      @user = create(:user)
    end

    it "if not logged in, it redirects to login page" do
      get user_path(@user.username)
      assert_redirected_to login_path
    end

    it "works if username exists" do
      sign_in_as(@user)
      get user_path(@user.username)
      assert_response :success
    end

    it "throws error if username does not exist" do
      sign_in_as(@user)
      another_user = build(:user)
      get user_path(another_user.username)
      assert_response :not_found
    end
  end
end
