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

    context "User is not signed in" do

      it "if profile is private, it throws an error" do
        @user.profile.update_attributes(:visibility => "is_private")
        get profile_path(@user.username)
        assert_response :not_found
      end

      it "if profile is network only, it throws an error" do
        @user.profile.update_attributes(:visibility => "is_network_only")
        get profile_path(@user.username)
        assert_response :not_found
      end

      it "if profile is public, it shows profile" do
        sign_in_as(@user)
        @user.profile.update_attributes(:visibility => "is_public")
        get profile_path(@user.username)
        assert_response :success
      end

    end

    context "User is signed in" do

      before(:each) do
        @another_user = create(:user)
        sign_in_as(@another_user)
      end

      it "if profile is private, it throws an error" do
        @user.profile.update_attributes(:visibility => "is_private")
        get profile_path(@user.username)
        assert_response :not_found
      end

      it "if profile is network only, it shows profile" do
        @user.profile.update_attributes(:visibility => "is_network_only")
        get profile_path(@user.username)
        assert_response :success
      end

      it "if profile is public, it shows profile" do
        sign_in_as(@user)
        @user.profile.update_attributes(:visibility => "is_public")
        get profile_path(@user.username)
        assert_response :success
      end

    end

  end
end
