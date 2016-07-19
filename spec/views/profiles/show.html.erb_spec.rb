require 'rails_helper'

RSpec.describe "profiles/show", type: :view do
  before(:each) do
    @profile = create(:user).profile
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Username/)
    expect(rendered).to match(@profile.user.name)
  end
end
