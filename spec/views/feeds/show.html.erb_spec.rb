require 'rails_helper'

RSpec.describe "feeds/show.html.erb", type: :view do
  let(:posts) { Post.paginate(:page => 1) }

  before do
    assign(:post, Post.new)
    @user = create(:user)
    assign(:current_user, @user)
    create_list(:friendship_request, 3, :recipient => @user)
    assign(:posts, posts)
  end

  it "has a header: Feed" do
   render
   expect(rendered).to have_text("Feed")
  end

  it "has a form for creating a new post" do
   render
   expect(rendered).to have_selector("form", text: "Post")
  end

  context "when there are posts to show" do
    it "shows posts" do
     render

     posts.each do |post|
       expect(rendered).to have_text(post.content)
       expect(rendered).to have_text(post.author.name)
     end
    end
  end

  context "when there are no posts to show" do
    before { Post.delete_all }

    it "shows message" do
     render
     expect(rendered).to have_text("There are no posts to show. Why don't you " +
        "write one to get started?")
    end

  end

end
