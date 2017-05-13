require 'rails_helper'

RSpec.describe "notifications/index.html.erb", type: :view do

  let(:current_user) { create(:user) }
  let!(:notification) { create(:post, :recipient => current_user) }

  before(:each) do
    assign(:current_user, current_user)
    assign(:notifications, Notification.for_user(current_user).paginate(:page => 1))
  end

  it "renders a button to mark all notifications seen" do
    render
    expect(rendered).to have_selector("button", text: "Mark all notifications as 'seen'")
  end
end