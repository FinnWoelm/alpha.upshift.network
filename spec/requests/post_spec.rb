require 'rails_helper'
include SignInHelper

RSpec.describe "Post", type: :request do
  describe "GET /post/:id" do

    before(:each) do
      @post = create(:post)
    end

    it "throws error if post does not exist" do
      @post.destroy
      get post_path(@post)
      assert_response :not_found
    end

  end
end
