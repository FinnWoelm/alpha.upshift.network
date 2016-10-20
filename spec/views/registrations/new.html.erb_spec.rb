require 'rails_helper'

RSpec.describe "registrations/new.html.erb", type: :view do

  before do
    assign(:user, User.new)
  end

  describe "registration form" do
    before { render }

    it { expect(rendered).to have_selector("div.input-field", text: "Name") }
    it { expect(rendered).to have_selector("div.input-field", text: "Username") }
    it { expect(rendered).to have_selector("div.input-field", text: "Email") }
    it { expect(rendered).to have_selector("div.input-field", text: "Password") }
    it { expect(rendered).to have_selector("div.input-field", text: "Confirm your password") }
    it { expect(rendered).to have_selector("button", text: "Sign Up") }

  end

end
