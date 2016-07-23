require 'rails_helper'
include SignInHelper

RSpec.describe "Like", type: :request do

  before(:each) do
    @user = create(:user)
    sign_in_as(@user)
  end

  describe "Posts" do

    before(:each) do
      @post = create(:post)
    end

    it "POST post/:id/like creates a like" do
      post like_path(:likable_id => @post.id, :likable_type => "Post")
      follow_redirect!
      assert_response :success
      @post.reload
      expect(@post.likes.size).to eq(1)
      expect(@post.likes_count).to eq(1)
      expect(@user.likes.size).to eq(1)
    end

    it "DELETE post/:id/unlike destroys a like" do
      post like_path(:likable_id => @post.id, :likable_type => "Post")
      delete unlike_path(:likable_id => @post.id, :likable_type => "Post")
      follow_redirect!
      assert_response :success
      @post.reload
      expect(@post.likes.size).to eq(0)
      expect(@post.likes_count).to eq(0)
      expect(@user.likes.size).to eq(0)
    end

  end

  describe "Comments" do

    before(:each) do
      @comment = create(:comment)
    end

    it "POST comment/:id/like creates a like" do
      post like_path(:likable_id => @comment.id, :likable_type => "Comment")
      follow_redirect!
      assert_response :success
      @comment.reload
      expect(@comment.likes.size).to eq(1)
      expect(@comment.likes_count).to eq(1)
      expect(@user.likes.size).to eq(1)
    end

    it "DELETE comment/:id/unlike destroys a like" do
      post like_path(:likable_id => @comment.id, :likable_type => "Comment")
      delete unlike_path(:likable_id => @comment.id, :likable_type => "Comment")
      follow_redirect!
      assert_response :success
      @comment.reload
      expect(@comment.likes.size).to eq(0)
      expect(@comment.likes_count).to eq(0)
      expect(@user.likes.size).to eq(0)
    end

  end

  describe "Some Invalid Type" do

    it "POST some-invalid-type/:id/like throws an error" do
      expect{post like_path(:likable_id => 0, :likable_type => "SomeInvalidType")}.to raise_error(ActionController::UnpermittedParameters)
    end

  end

end
