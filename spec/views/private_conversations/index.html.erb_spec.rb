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

end
