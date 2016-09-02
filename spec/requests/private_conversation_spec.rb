require 'rails_helper'
include SignInHelper

RSpec.describe "Private Conversation", type: :request do
  describe "GET /conversation/:id" do

    before(:each) do
      @user = create(:user)
      sign_in_as(@user)

      @conversation = create(:private_conversation, :sender => @user)
      @message = create(:private_message, :conversation => @conversation,
        :sender => @conversation.participants_other_than(@user).first)
    end

    it "marks conversation as read" do
      expect(@user.unread_private_conversations.size).to eq(1)

      get private_conversation_path @conversation
      assert_response :success

      expect(@user.unread_private_conversations.size).to eq(0)
    end

  end
end
