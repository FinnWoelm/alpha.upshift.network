require "rails_helper"

RSpec.describe "routes for root", :type => :routing do

  context "when user is signed in" do
    before do
      expect_any_instance_of(AuthenticationConstraint).
        to receive(:matches?).
        and_return(true)
    end

    it "routes to feeds#show" do

      expect(:get => "/").to route_to(
        :controller => "feeds",
        :action => "show"
      )

    end
  end

  context "when user is not signed in" do
    before do
      expect_any_instance_of(AuthenticationConstraint).
        to receive(:matches?).
        and_return(false)
    end

    it "routes to static#home" do

      expect(:get => "/").to route_to(
        :controller => "static",
        :action => "home"
      )

    end
  end

end
