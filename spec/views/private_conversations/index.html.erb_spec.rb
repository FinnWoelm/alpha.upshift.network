require 'rails_helper'

RSpec.describe "private_conversations/index.html.erb", type: :view do

  let(:current_user) { create(:user) }
  let!(:private_conversations) { create_list(:private_conversation, 5, :sender => current_user ) }

  before(:each) do
    assign(:current_user, current_user)
    assign(:private_conversations, PrivateConversation.paginate(:page => 1))
  end

  it "shows all private conversations of the user" do
    render

    private_conversations.each do |c|
      expect(rendered).to have_text(c.recipient.name)
    end

    assert_select "div.preview_conversation", :count => 5
  end

  it "has an option to delete the conversation" do
    render
    assert_select "a", :text => "Delete", :count => 5
  end

end
