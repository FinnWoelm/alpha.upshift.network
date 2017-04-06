require "rails_helper"

RSpec.describe "routes for profiles", :type => :routing do
  it "/user routes to profile page" do

    username = "user"

    expect(:get => "/" + username).to route_to(
      :controller => "profiles",
      :action => "show",
      :username => username
    )
  end

  it "/some_user_name routes to profile page" do

    username = "some_user"

    expect(:get => "/" + username).to route_to(
      :controller => "profiles",
      :action => "show",
      :username => username
    )
  end

  it "/my_username99 routes to profile page" do

    username = "my_username99"

    expect(:get => "/" + username).to route_to(
      :controller => "profiles",
      :action => "show",
      :username => username
    )
  end

  it "/_abc does not route to profile page" do

    username = "_abc"

    expect(:get => "/" + username).not_to route_to(
      :controller => "profiles",
      :action => "show",
      :username => username
    )
  end

  it "/abc_ does not route to profile page" do

    username = "abc_"

    expect(:get => "/" + username).not_to route_to(
      :controller => "profiles",
      :action => "show",
      :username => username
    )
  end

  it "/i!!ega!_char$ does not route to profile page" do

    username = "i!!ega!_char$"

    expect(:get => "/" + username).not_to route_to(
      :controller => "profiles",
      :action => "show",
      :username => username
    )
  end

  it "/image_file.jpg does not route to profile page" do

    username = "image_file.jpg"

    expect(:get => "/" + username).not_to route_to(
      :controller => "profiles",
      :action => "show",
      :username => username
    )
  end

  it "/ab does not route to profile page" do

    username = "ab"

    expect(:get => "/" + username).not_to route_to(
      :controller => "profiles",
      :action => "show",
      :username => username
    )
  end

  it "/longerthan26charactersfails does not route to profile page" do

    username = "longerthan26charactersfails"

    expect(:get => "/" + username).not_to route_to(
      :controller => "profiles",
      :action => "show",
      :username => username
    )
  end

end
