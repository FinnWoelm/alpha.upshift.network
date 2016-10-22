require "rails_helper"

RSpec.describe "routes for registration", :type => :routing do

  it "routes to registration#new" do
    expect(:get => "/signup").to route_to(
      :controller => "registrations",
      :action => "new"
    )
  end

  it "routes to registrations#create" do
    expect(:post => "/signup").to route_to(
      :controller => "registrations",
      :action => "create"
    )
  end

  it "routes to registrations#confirm" do
    expect(:get => "/signup/confirm?email=myemail@address.com&registration_token=MYTOKEN").to route_to(
      :controller => "registrations",
      :action => "confirm",
      :email => "myemail@address.com",
      :registration_token => "MYTOKEN"
    )
  end

  it "routes to registrations#confirmation_reminder" do
    expect(:get => "/signup/confirmation_reminder").to route_to(
      :controller => "registrations",
      :action => "confirmation_reminder"
    )
  end

  it "routes to registrations#resend_confirmation" do
    expect(:post => "/signup/resend_confirmation").to route_to(
      :controller => "registrations",
      :action => "resend_confirmation"
    )
  end

end
