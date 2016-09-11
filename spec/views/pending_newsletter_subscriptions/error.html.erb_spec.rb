require 'rails_helper'

RSpec.describe "pending_newsletter_subscriptions/error", type: :view do

  before do
    @pending_newsletter_subscription =
      assign(:pending_newsletter_subscription,
        nil
      )
  end

  it "renders error" do
    render
    expect(rendered).to have_text("Error")
  end

end
