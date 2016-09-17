require 'rails_helper'

RSpec.describe "private_conversations/new.html.erb", type: :view do

  let(:current_user) { create(:user) }
  let(:recipient) { create(:user) }
  let(:sender) { current_user }
  let(:private_conversation) {
    build(:private_conversation, sender: sender, recipient: recipient)
  }

  before do
    assign(:current_user, current_user)
    assign(:private_conversation, private_conversation)
  end

  it "renders a form for recipient and message" do
    render

    expect(rendered).to have_selector("form")
    expect(rendered).to have_selector("label", :text => "Recipient")
    expect(rendered).to have_selector("label", :text => "Message")
  end

  describe "validation errors" do

    it "shows error if recipient is invalid" do
      private_conversation.recipient = recipient.username + "abc"
      private_conversation.valid?

      render

      expect(private_conversation.errors.size).to eq(1)
      expect(rendered).to have_text("Recipient does not exist or their profile is private")
    end

    it "shows error if recipient profile is private" do
      recipient.profile.is_private!
      private_conversation.valid?

      render

      expect(private_conversation.errors.size).to eq(1)
      expect(rendered).to have_text("Recipient does not exist or their profile is private")
    end

  end

end
