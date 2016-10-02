require 'rails_helper.rb'

feature 'Post' do

  scenario 'User can write a post' do
    given_i_am_logged_in_as_a_user
    when_i_write_a_post
    then_i_should_have_a_post_on_my_profile
  end

  scenario 'User can delete a post' do
    given_i_am_logged_in_as_a_user
    when_i_write_a_post
    and_i_delete_the_post
    then_i_should_not_have_a_post_on_my_profile
  end

  scenario 'User can view a post' do
    given_i_am_logged_in_as_a_user
    when_i_write_a_post
    and_click_on_the_post_timestamp
    then_i_should_see_the_post_on_a_separate_page
  end

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def when_i_write_a_post
    visit profile_path(@user)
    @my_post_content = Faker::Lorem.paragraph
    fill_in 'post_content', with: @my_post_content
    click_button "Post"
  end

  def then_i_should_have_a_post_on_my_profile
    expect(@user.posts.size).to eq(1)
    expect(page).to have_content(@my_post_content)
  end

  def and_i_delete_the_post
    click_link "Delete Post"
  end

  def then_i_should_not_have_a_post_on_my_profile
    expect(@user.posts.size).to eq(0)
    expect(page).not_to have_content(@my_post_content)
  end

  def and_click_on_the_post_timestamp
    click_link "ago"
  end

  def then_i_should_see_the_post_on_a_separate_page
    expect(page).to have_current_path(post_path(@user.posts.first))
    expect(page).to have_content(@my_post_content)
  end

end
