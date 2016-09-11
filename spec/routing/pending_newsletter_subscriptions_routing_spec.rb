require "rails_helper"

RSpec.describe "routes for pending newsletter subscriptions", :type => :routing do
  it "routes to confirmation page" do

    @token = Faker::Internet.password
    @email = Faker::Internet.email

    expect(
      :get => "/pending_newsletter_subscriptions/confirm?" +
        "email=#{@email}&confirmation_token=#{@token}"
      ).
      to route_to(
        :controller => "pending_newsletter_subscriptions",
        :action => "confirm",
        :email => @email,
        :confirmation_token => @token
      )
  end
end
