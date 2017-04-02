require 'rails_helper'

RSpec.describe "private_conversations/show", type: :view do
  let(:current_user) { create(:user) }
  let(:private_conversation) { create(:private_conversation, :sender => current_user ) }
  let(:private_messages) do
    create_list(:private_message, 5, :conversation => private_conversation)
    private_conversation.messages.paginate(:page => nil)
  end

  before(:each) do
    assign(:current_user, current_user)
    assign(:private_conversation, private_conversation)
    assign(:private_messages, private_messages)
    assign(:private_message, private_conversation.messages.build(:sender => current_user))
  end

  it "renders oldest messages first" do

    render

    expect(private_messages[4].content).to appear_before(private_messages[3].content)
    expect(private_messages[3].content).to appear_before(private_messages[2].content)
    expect(private_messages[2].content).to appear_before(private_messages[1].content)
    expect(private_messages[1].content).to appear_before(private_messages[0].content)
  end

end
