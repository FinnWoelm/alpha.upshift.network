require 'rails_helper'

RSpec.describe "sessions/new.html.erb", type: :view do

  it "renders login form" do
    render

    assert_select "form[action=?][method=?]", login_path, "post" do

      assert_select "input#email"

      assert_select "input#password"
    end
  end

end
