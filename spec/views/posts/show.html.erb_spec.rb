require 'rails_helper'

RSpec.describe "posts/show", type: :view do
  before(:each) do
    @post = assign(:post, create(:post, :content => "Some text"))
  end

  it "renders author, content, and timestamp" do
    render
    expect(rendered).to have_text(@post.author.name)
    expect(rendered).to have_text("Some text")
    expect(rendered).to have_text(render_timestamp(@post.created_at))
  end

  it "shows new comment form if user is signed in" do
    @current_user = create(:user)
    render
    expect(rendered).to have_text("New Comment")
  end

  it "does not show new comment form if user is not signed in" do
    @current_user = nil
    render
    expect(rendered).not_to have_text("New Comment")
  end

end
