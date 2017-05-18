require 'rails_helper'

RSpec.describe "friendship_requests/index", type: :view do
  let(:requests) { @user.friendship_requests_received.paginate(:page => 1) }
  before(:each) do
    @user = create(:user)
    create_list(:friendship_request, 3, :recipient => @user)
    assign(:friendship_requests, requests)
  end

  it "renders a list of friendship_requests" do
    render
    expect(rendered).to have_text(requests.first.sender.name)
    expect(rendered).to have_text(requests.first.sender.name)

    expect(rendered).to have_selector("button", text: "Accept", count: requests.size)
    expect(rendered).to have_selector("button", text: "Reject", count: requests.size)

  end
end
