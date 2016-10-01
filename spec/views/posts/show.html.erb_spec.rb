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
    expect(rendered).to have_selector("form", text: "Comment")
  end

  it "does not show new comment form if user is not signed in" do
    @current_user = nil
    render
    expect(rendered).not_to have_text("New Comment")
  end

  it "renders oldest comments first" do
    @comments_to_check = []
    5.times { @comments_to_check << create(:comment, :author => @post.author, :post => @post) }

    @post = Post.with_associations.find_by id: @post.id

    render

    expect(@comments_to_check[0].content).to appear_before(@comments_to_check[1].content)
    expect(@comments_to_check[1].content).to appear_before(@comments_to_check[2].content)
    expect(@comments_to_check[2].content).to appear_before(@comments_to_check[3].content)
    expect(@comments_to_check[3].content).to appear_before(@comments_to_check[4].content)

  end

end
