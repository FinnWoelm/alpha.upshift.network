require 'rails_helper'

RSpec.describe "private_conversations/show", type: :view do
  before(:each) do
    @current_user = create(:user)
  end

  it "renders most recent messages first" do
    @most_recent_messages = []
    @conversation = create(:private_conversation, :sender => @current_user )
    5.times { @most_recent_messages.unshift create(:private_message, :conversation => @conversation) }

    @private_conversation = @current_user.private_conversations.with_associations.find_by id: @conversation.id
    @private_message = @private_conversation.messages.build(:sender => @current_user)

    render

    expect(@most_recent_messages[0].content).to appear_before(@most_recent_messages[1].content)
    expect(@most_recent_messages[1].content).to appear_before(@most_recent_messages[2].content)
    expect(@most_recent_messages[2].content).to appear_before(@most_recent_messages[3].content)
    expect(@most_recent_messages[3].content).to appear_before(@most_recent_messages[4].content)
  end

end
