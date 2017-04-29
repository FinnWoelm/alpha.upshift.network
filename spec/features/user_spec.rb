require 'rails_helper.rb'

feature 'User' do

  scenario 'User visits own profile' do
    given_i_am_logged_in_as_a_user
    when_i_visit_my_own_page
    then_i_should_see_my_profile
  end

  scenario "User visits another user's profile" do
    given_i_am_logged_in_as_a_user
    when_i_visit_the_page_of_another_user
    then_i_should_see_their_profile
  end

  scenario 'User can write a post on the profile of someone else' do
    given_i_am_logged_in_as_a_user

    # when I visit the page of another user
    @another_user = create(:user)
    visit @another_user

    # and I write a post
    @my_post_content = Faker::Lorem.paragraph
    fill_in 'post_content', with: @my_post_content
    click_button "Post"

    # then I should have posted on the other user's profile
    expect(page).to have_content(@my_post_content)
  end

  def given_i_am_logged_in_as_a_user
    @user = create(:user)
    visit login_path
    fill_in 'email',    with: @user.email
    fill_in 'password', with: @user.password
    click_button 'Login'
  end

  def when_i_visit_my_own_page
    visit @user
  end

  def when_i_visit_the_page_of_another_user
    @another_user = create(:user)
    visit @another_user
  end

  def then_i_should_see_my_profile
    expect(page).to have_content(@user.name)
  end

  def then_i_should_see_their_profile
    expect(page).to have_current_path("/" + @another_user.username)
    expect(page).to have_content(@another_user.name)
  end

end
