require 'rails_helper'
include SignInHelper

RSpec.describe "Post", type: :request do
  describe "GET /post/:id" do

    before(:each) do
      @post = create(:post)
    end

    it "throws error if post does not exist" do
      another_post = build(:post) # build but not create
      get post_path(another_post)
      assert_response :not_found
    end

  end
end
