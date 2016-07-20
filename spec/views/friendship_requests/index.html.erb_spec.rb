require 'rails_helper'

RSpec.describe "friendship_requests/index", type: :view do
  before(:each) do
    @user = create(:user)
    @requests = assign(:friendship_requests, [
      create(:friendship_request, :recipient => @user),
      create(:friendship_request, :recipient => @user)
    ])
  end

  it "renders a list of friendship_requests" do
    render
    expect(rendered).to match(@requests.first.sender.name)
    expect(rendered).to match(@requests.first.sender.name)

    assert_select "input[type=submit][value='Accept']", :count => @requests.size
    assert_select "tr>td", :text => "Reject", :count => @requests.size

  end
end
