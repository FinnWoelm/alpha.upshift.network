require 'rails_helper.rb'

feature 'Comment' do

  scenario 'User can write a comment' do
    given_i_am_logged_in_as_a_user
    and_someone_has_written_a_post
    when_i_read_the_post
    and_write_a_comment
    then_the_post_should_have_my_comment
  end

  scenario 'User can delete a comment' do
    given_i_am_logged_in_as_a_user
    and_someone_has_written_a_post
    when_i_read_the_post
    and_write_a_comment
    and_delete_the_comment
    then_the_post_should_not_have_my_comment
  end

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def and_someone_has_written_a_post
    @post = create(:post)
  end

  def when_i_read_the_post
    visit post_path @post
  end

  def and_write_a_comment
    @my_comment_content = Faker::Lorem.paragraph
    fill_in "comment_content", with: @my_comment_content
    click_on "Comment"
  end

  def then_the_post_should_have_my_comment
    expect(@post.comments.size).to eq(1)
    expect(@user.comments.size).to eq(1)
    expect(page).to have_content(@my_comment_content)
  end

  def and_delete_the_comment
    click_link "Delete Comment"
  end

  def then_the_post_should_not_have_my_comment
    expect(@post.comments.size).to eq(0)
    expect(@user.comments.size).to eq(0)
    expect(page).not_to have_content(@my_comment_content)
  end

end
