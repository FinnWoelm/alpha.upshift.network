require 'rails_helper'

RSpec.describe "private_conversations/index.html.erb", type: :view do

  before(:each) do
    @current_user = create(:user)
  end

  it "shows all private conversations of the user" do

    @my_conversations = []
    5.times do
      @my_conversations << create(:private_conversation, :sender => @current_user)
    end

    @private_conversations = @current_user.private_conversations

    render

    @my_conversations.each do |c|
      expect(rendered).to have_text(c.recipient.name)
    end
    assert_select "div.private_conversation_preview", :count => 5
  end

  it "renders conversations in order of most recent activity" do
    @most_recently_active_conversations = []
    5.times { @most_recently_active_conversations << build(:private_conversation, :sender => @current_user) }

    20.times do
      conversation = @most_recently_active_conversations[rand(0..@most_recently_active_conversations.size-1)]
      create(:private_message, :conversation => conversation, :sender => @current_user)

      # move conversation to front of array
      @most_recently_active_conversations -= [conversation]
      @most_recently_active_conversations.unshift conversation

    end

    @private_conversations =
      @current_user.
      private_conversations.
      most_recent_activity_first.
      includes(:participants).
      includes(:most_recent_message)

    render

    previous_recipient_name = ""

    @most_recently_active_conversations.each do |conversation|
      if not previous_recipient_name.empty? and not conversation.new_record?
        expect(previous_recipient_name).
          to appear_before(conversation.recipient.name)
        previous_recipient_name = conversation.recipient.name
      end
    end

  end

  it "has an option to delete the conversation" do

    @private_conversations = []
    5.times do
      @private_conversations << create(:private_conversation, :sender => @current_user)
    end

    render

    assert_select "a", :text => "Delete", :count => 5

  end

end
