require 'rails_helper'

RSpec.describe "sessions/destroy.html.erb", type: :view do

  it "renders logout page" do
    render

    assert_select "p", :text => /.*logged out.*/

  end

end
