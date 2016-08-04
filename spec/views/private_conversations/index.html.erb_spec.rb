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
    assert_select "div.private_conversation", :count => 5
  end

  it "does not show any private conversations of other users" do

    @not_my_conversations = []
    5.times do
      @not_my_conversations << create(:private_conversation)
    end

    @private_conversations = @current_user.private_conversations

    render

    @not_my_conversations.each do |c|
      expect(rendered).not_to have_text(c.recipient.name)
    end
    assert_select "div.private_conversation", :count => 0
    expect(rendered).to have_text("You currently have no conversations.")
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

    expect(@most_recently_active_conversations[0].recipient.name).to appear_before(@most_recently_active_conversations[1].recipient.name)
    expect(@most_recently_active_conversations[1].recipient.name).to appear_before(@most_recently_active_conversations[2].recipient.name)
    expect(@most_recently_active_conversations[2].recipient.name).to appear_before(@most_recently_active_conversations[3].recipient.name)
    expect(@most_recently_active_conversations[3].recipient.name).to appear_before(@most_recently_active_conversations[4].recipient.name)

  end

end
