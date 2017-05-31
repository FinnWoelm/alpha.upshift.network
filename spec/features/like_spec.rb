require 'rails_helper.rb'
require 'support/features/login_helper.rb'

feature 'Like' do

  scenario 'User can like post' do
    given_i_am_logged_in_as_a_user
    and_i_view_a_post
    when_i_like_the_post
    then_the_post_should_have_my_like
  end

  scenario 'User can unlike post' do
    given_i_am_logged_in_as_a_user
    and_i_view_a_post
    when_i_like_the_post
    and_i_unlike_the_post
    then_the_post_should_not_have_my_like
  end

  scenario 'User can like comment' do
    given_i_am_logged_in_as_a_user
    and_i_view_a_post_with_a_comment
    when_i_like_the_comment
    then_the_comment_should_have_my_like
  end

  scenario 'User can unlike comment' do
    given_i_am_logged_in_as_a_user
    and_i_view_a_post_with_a_comment
    when_i_like_the_comment
    and_i_unlike_the_comment
    then_the_comment_should_not_have_my_like
  end

  def and_i_view_a_post
    @post = create(:post)
    visit post_path @post
  end

  def when_i_like_the_post
    within(".post") do
      click_on "LIKE"
    end
  end

  def then_the_post_should_have_my_like
    @post.reload
    expect(@post.likes.size).to eq(1)
    expect(@user.likes.size).to eq(1)
    expect(page).to have_selector(".post div.actions", text: "1")
  end

  def and_i_unlike_the_post
    within(".post") do
      click_on "UNLIKE"
    end
  end

  def then_the_post_should_not_have_my_like
    @post.reload
    expect(@post.likes.size).to eq(0)
    expect(@user.likes.size).to eq(0)
    expect(page).not_to have_selector(".post div.actions", text: "1")
  end

  def and_i_view_a_post_with_a_comment
    @comment = create(:comment)
    visit post_path @comment.commentable
  end

  def when_i_like_the_comment
    within(".comment .like_button", match: :first) do
      click_on "0"
    end
  end

  def then_the_comment_should_have_my_like
    @comment.reload
    expect(@comment.likes.size).to eq(1)
    expect(@user.likes.size).to eq(1)
    expect(page).to have_selector(".comment .btn-flat", text: "1")
  end

  def and_i_unlike_the_comment
    within(".comment .unlike_button", match: :first) do
      click_on "1"
    end
  end

  def then_the_comment_should_not_have_my_like
    @comment.reload
    expect(@comment.likes.size).to eq(0)
    expect(@user.likes.size).to eq(0)
    expect(page).not_to have_selector(".comment .btn-flat", text: "1")
  end

end
