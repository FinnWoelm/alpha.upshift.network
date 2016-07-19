require "rails_helper"

RSpec.describe "routes for profiles", :type => :routing do
  it "routes to profile page" do

    @user = create(:user)

    expect(:get => "/" + @user.username).to route_to(
      :controller => "profiles",
      :action => "show",
      :username => @user.username
    )
  end
end
