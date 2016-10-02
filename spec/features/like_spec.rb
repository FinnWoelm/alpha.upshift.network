require 'rails_helper.rb'

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

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
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
    expect(page).to have_content("thumb_up 1")
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
    expect(page).to have_content("thumb_up 0")
  end

  def and_i_view_a_post_with_a_comment
    @comment = create(:comment)
    visit post_path @comment.post
  end

  def when_i_like_the_comment
    within(".comment", match: :first) do
      click_on "thumb_up"
    end
  end

  def then_the_comment_should_have_my_like
    @comment.reload
    expect(@comment.likes.size).to eq(1)
    expect(@user.likes.size).to eq(1)
    expect(page).to have_content("thumb_up 1")
  end

  def and_i_unlike_the_comment
    within(".comment", match: :first) do
      click_on "thumb_up"
    end
  end

  def then_the_comment_should_not_have_my_like
    @comment.reload
    expect(@comment.likes.size).to eq(0)
    expect(@user.likes.size).to eq(0)
    expect(page).to have_content("thumb_up 0")
  end

end
