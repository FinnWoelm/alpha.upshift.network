require "rails_helper"

RSpec.describe "routes for user attachments", :type => :routing do

  it "/username/profile_picture/medium.jpg routes to profile picture" do
    expect(:get => "/upshift_user/profile_picture/medium.jpg").to route_to(
      :controller => "user/attachments",
      :action => "show",
      :username => "upshift_user",
      :attachment => "profile_picture",
      :size => "medium",
      :format => "jpg"
    )
  end

  it "/username/profile_picture/large.jpg routes to profile picture" do
    expect(:get => "/upshift_user/profile_picture/large.jpg").to route_to(
      :controller => "user/attachments",
      :action => "show",
      :username => "upshift_user",
      :attachment => "profile_picture",
      :size => "large",
      :format => "jpg"
    )
  end

  it "/username/profile_banner/original.jpg routes to profile picture" do
    expect(:get => "/upshift_user/profile_banner/original.jpg").to route_to(
      :controller => "user/attachments",
      :action => "show",
      :username => "upshift_user",
      :attachment => "profile_banner",
      :size => "original",
      :format => "jpg"
    )
  end

  it "/username/profile_picture/unsupported_size.jpg does not route to profile picture" do
    expect(:get => "/upshift_user/profile_picture/unsupported_size.jpg").not_to route_to(
      :controller => "user/attachments",
      :action => "show",
      :username => "upshift_user",
      :attachment => "profile_picture",
      :size => "unsupported_size",
      :format => "jpg"
    )
  end

end
