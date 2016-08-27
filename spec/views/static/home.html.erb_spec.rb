require 'rails_helper'

RSpec.describe "static/home", type: :view do

  it "renders join button" do
    render
    expect(rendered).to have_text "Join"
    assert_select "a[href='#join']"
  end

  it "renders join newsletter form" do
    render
    assert_select "form"
  end

end
