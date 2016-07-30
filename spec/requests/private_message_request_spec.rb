require 'rails_helper'
include SignInHelper

RSpec.describe "Private Message", type: :request do
  describe "POST /message" do

    before(:each) do
      @user = create(:user)
      sign_in_as(@user)

      # create a conversation partner
      @conversation_partner = create(:user)
    end

    # The standard behavior: User sends a message to a conversation that already
    # exists
    context "in an existing conversation" do

      before(:each) do
        # Create initial conversation with one message
        @conversation = create(:private_conversation, :sender => @user, :recipient => @conversation_partner)
        create(:private_message, :conversation => @conversation, :sender => @user)
      end

      it "adds new messages to existing conversations" do
        @new_message = build(:private_message, :private_conversation_id => @conversation.id, :recipient => @conversation_partner.username)
        post private_messages_path, :params => {:private_message => @new_message.attributes}

        assert_response :redirect, private_conversation_path(@conversation)
        expect(PrivateMessage.all.size).to eq(2)
      end

    end

    # The conversation is deleted between the user loading it and sending a
    # new mesage
    context "in a freshly removed conversation" do

      before(:each) do
        # Create initial conversation with one message
        @conversation = create(:private_conversation, :sender => @user, :recipient => @conversation_partner)
        create(:private_message, :conversation => @conversation, :sender => @user)

        # delete initial conversation
        @conversation.destroy
        expect(PrivateConversation.all.size).to eq(0)

        # build a new message
        @new_message =
          PrivateMessage.new(
            :sender => @user,
            :private_conversation_id => @conversation.id,
            :recipient => @conversation_partner.username,
            :content => Faker::Lorem.paragraph)

        # turn new message into params
        @new_message_params = @new_message.attributes
        @new_message_params[:recipient] = @conversation_partner.username
      end


      it "creates a new conversation if conversation was deleted in the meantime" do
        post private_messages_path, :params => {:private_message => @new_message_params}

        assert_response :redirect, private_conversation_path(PrivateConversation.first)
        expect(PrivateConversation.all.size).to eq(1)
        expect(PrivateMessage.all.size).to eq(1)
      end

      it "does not create a new conversation if conversation was deleted and sender cannot see recipient profile" do
        @conversation_partner.profile.is_private!

        post private_messages_path, :params => {:private_message => @new_message_params}

        assert_response :success
        expect(PrivateConversation.all.size).to eq(0)
        expect(PrivateMessage.all.size).to eq(0)
      end

    end

    # The request comes from the conversation/new page
    context "and create a new conversation" do

      it "creates a new conversation if conversation does not already exist" do
        expect(PrivateConversation.all.size).to eq(0)

        @new_message =
          PrivateMessage.new(
            :sender => @user,
            :recipient => @conversation_partner.username,
            :content => Faker::Lorem.paragraph)

        @new_message_params = @new_message.attributes
        @new_message_params[:recipient] = @conversation_partner.username

        post private_messages_path, :params => {:private_message => @new_message_params}

        assert_response :redirect, private_conversation_path(PrivateConversation.first)
        expect(PrivateConversation.all.size).to eq(1)
        expect(PrivateMessage.all.size).to eq(1)
      end
    end

  end
end
