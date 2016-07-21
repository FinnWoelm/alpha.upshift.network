require 'rails_helper'

RSpec.describe "posts/show", type: :view do
  before(:each) do
    @post = assign(:post, create(:post, :content => "Some text"))
  end

  it "renders author, content, and timestamp" do
    render
    expect(rendered).to match(@post.author.name)
    expect(rendered).to match(/Some text/)
    expect(rendered).to match(render_timestamp(@post.created_at))
  end
end
