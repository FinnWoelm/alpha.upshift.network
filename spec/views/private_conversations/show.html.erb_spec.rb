require 'rails_helper'

RSpec.describe "private_conversations/show", type: :view do
  let(:current_user) { create(:user) }
  let(:most_recent_messages) { [] }
  let(:new_conversation) { create(:private_conversation, :sender => current_user ) }
  let(:private_conversation) { current_user.private_conversations.with_associations.find_by id: new_conversation.id }

  before(:each) do
    assign(:current_user, current_user)
    5.times { most_recent_messages.unshift create(:private_message, :conversation => new_conversation) }
    assign(:private_conversation, private_conversation)
    assign(:private_message, private_conversation.messages.build(:sender => current_user))
  end

  it "renders oldest messages first" do

    render

    expect(most_recent_messages[4].content).to appear_before(most_recent_messages[3].content)
    expect(most_recent_messages[3].content).to appear_before(most_recent_messages[2].content)
    expect(most_recent_messages[2].content).to appear_before(most_recent_messages[1].content)
    expect(most_recent_messages[1].content).to appear_before(most_recent_messages[0].content)
  end

end
