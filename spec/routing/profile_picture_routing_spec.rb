require "rails_helper"

RSpec.describe "routes for profile pictures", :type => :routing do

  it "/username/profile_picture/medium.jpg routes to profile picture" do
    expect(:get => "/upshift_user/profile_picture/medium.jpg").to route_to(
      :controller => "user/profile_pictures",
      :action => "show",
      :username => "upshift_user",
      :size => "medium",
      :format => "jpg"
    )
  end

  it "/username/profile_picture/large.jpg routes to profile picture" do
    expect(:get => "/upshift_user/profile_picture/large.jpg").to route_to(
      :controller => "user/profile_pictures",
      :action => "show",
      :username => "upshift_user",
      :size => "large",
      :format => "jpg"
    )
  end

  it "/username/profile_picture/unsupported_size.jpg does not route to profile picture" do
    expect(:get => "/upshift_user/profile_picture/unsupported_size.jpg").not_to route_to(
      :controller => "user/profile_pictures",
      :action => "show",
      :username => "upshift_user",
      :size => "unsupported_size",
      :format => "jpg"
    )
  end

end
