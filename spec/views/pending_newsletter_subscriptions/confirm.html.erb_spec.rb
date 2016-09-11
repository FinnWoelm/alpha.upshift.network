require 'rails_helper'

RSpec.describe "pending_newsletter_subscriptions/confirm", type: :view do

  before do
    @pending_newsletter_subscription =
      assign(:pending_newsletter_subscription,
        create(:pending_newsletter_subscription)
      )
  end

  it "renders thank you" do
    render
    expect(rendered).to have_text("Thank you")
    expect(rendered).to have_text(@pending_newsletter_subscription.name)
    expect(rendered).to have_text(@pending_newsletter_subscription.email)
  end

end
